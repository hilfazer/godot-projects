extends Node
class_name GameScene

const GameCreatorGd          = preload("./GameCreator.gd")
const LevelLoaderGd          = preload("res://engine/game/LevelLoader.gd")

enum Params { Module, PlayerUnitsData, SaveFileName }
enum State { Initial, Creating, Saving, Running, Finished }

var currentLevel : LevelBase: set = setCurrentLevel
var _module : ModuleState: set = setCurrentModule
var _state : State = State.Initial
var _pause := true: set = setPause

@onready var _creator                  :GameCreatorGd  = $"GameCreator"
@onready var _player_agent             :PlayerAgent = $"PlayerAgent"


signal gameStarted()
signal gameFinished()
signal currentLevelChanged( level )
signal nonmatching_save_file_selected( saveFile )


func _ready():
	_creator.initialize( self, self )

	_player_agent.initialize( currentLevel )
	_player_agent.travel_requested.connect(Callable(self, "_travel"))

	var params = get_meta(Constants.Meta.SwitchParams)
	set_meta(Constants.Meta.SwitchParams, null)
	if params == null:
		return

	if !params.has( Params.Module ) && !params.has(Params.SaveFileName):
		Debug.error( self, "No module and no save file. Can't create game." )
		finish()
		return

	assert( !(params.has(Params.PlayerUnitsData) && params.has(Params.SaveFileName)) )

	# creating new game from module
	if params.has( Params.Module ):
		var module : ModuleState = params[Params.Module]
		var unitsData = params[Params.PlayerUnitsData] \
			if params.has( Params.PlayerUnitsData ) \
			else []
		call_deferred( "createGame", module, unitsData )

	# creating game from save file
	elif params.has(Params.SaveFileName):
		call_deferred( "createGameFromFile", params[Params.SaveFileName] )
	else:
		Debug.error( self, "Can't create the game." )


func _exit_tree():
	get_tree().paused = false
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func createGame( module : ModuleState, unitsCreationData : Array ):
	assert(module)
	_changeState( State.Creating )
	_creator.call_deferred( "createFromModule", module, unitsCreationData )
	var result = await _creator.createFinished

	if result != OK:
		Debug.error(self, "GameScene: could not create game")
		finish()
	else:
		start()


func createGameFromFile( filePath : String ):
	assert(!_module)
	_changeState( State.Creating )
	var result = await _creator.createFromFile(filePath)

	if result != OK:
		Debug.error(self, "GameScene: could not create game from file %s" % filePath)
		finish()
	else:
		start()


func saveGame( filepath : String ):
	assert( _state == State.Running )
	_changeState( State.Saving )
	_module.saveLevel( currentLevel, true )
	_module.savePlayerData( _player_agent )

	var result = _module.saveToFile( filepath )

	if result != OK:
		Debug.error( self, "Saving game to file %s failed." % filepath )
	_changeState( State.Running )


func loadGame( filepath : String ):
	assert( _state in [State.Running, State.Initial] )
	assert( _module )

	if not _module.moduleMatches(filepath):
		_changeState(State.Finished)
		nonmatching_save_file_selected.emit(filepath)
		return

	var previousState = _state
	_changeState( State.Creating )

	var result = await _creator.createFromFile( filepath )
	start() if result == OK else _changeState( previousState )


func start():
	_changeState( State.Running )
	Debug.info( self, "-----\nGAME START\n-----" )
	emit_signal("gameStarted")


func finish():
	_changeState( State.Finished )
	emit_signal( "gameFinished" )


func loadLevel( levelName : String ) -> Error:
	if currentLevel:
		_changeState( State.Saving )
		for unit in _player_agent.getUnits():
			assert( unit is UnitBase )
			unit.get_parent().remove_child( unit )
		_module.saveLevel( currentLevel, false )

	_changeState( State.Creating )
	var result :Error = await _creator.loadLevel( levelName, true )
	_changeState( State.Running )
	return result


func unloadCurrentLevel() -> Error:
	_changeState( State.Creating )
	var result :Error = await _creator.unloadCurrentLevel()
	_changeState( State.Running )
	return result


func setCurrentModule( module : ModuleState ):
	_module = module


func setCurrentLevel( level : LevelBase ):
	if level == currentLevel:
		return

	assert( level == null or self.is_ancestor_of( level ) )
	currentLevel = level
	_player_agent.setCurrentLevel(level)
	emit_signal("currentLevelChanged", level)


func setPause( paused : bool ):
	_pause = paused
	updatePaused()


func updatePaused():
	get_tree().paused = _pause or $"Pause/PlayerPause"._pause
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func get_player_units() -> Array[UnitBase]:
	return _player_agent.getUnits()
	
	
func set_player_units( units :Array[UnitBase] ) -> void:
	_player_agent.set_player_units(units)


func _travel( transition_zone : Area2D ):
	var levelAndEntranceNames : PackedStringArray = _module.data().\
			get_target_level_and_transition_zone( currentLevel.name, transition_zone.name )

	if levelAndEntranceNames.is_empty():
		return

	_changeState( State.Creating )

	var levelName : String = levelAndEntranceNames[0].get_file().get_basename()
	var transition_zone_name : String = levelAndEntranceNames[1]
	var result : int = await loadLevel( levelName )

	if result != OK:
		return

	_player_agent.set_physics_process(false)

	var notAdded = LevelLoaderGd.insertPlayerUnits(
			_player_agent.getUnits(), currentLevel, transition_zone_name )

	# TODO: replace it with _changeState( State.Running ) that unpauses the game
	# but first remove that from GameScene.loadLevel()
	await get_tree().process_frame
	_player_agent.set_physics_process(true)


	for unit in notAdded:
		Debug.info(self, "Unit '%s' not added to level" % unit.name)


func _changeState( state : State ):
	assert( _state != State.Finished )

	if state == _state:
		Debug.warn( self, "changing to same state: %s" % state )
		return

	if state == State.Finished:
		setPause(false)

	elif state == State.Running:
		setPause(false)

	elif state == State.Creating:
		setPause(true)

	elif state == State.Saving:
		setPause(true)

	_state = state
