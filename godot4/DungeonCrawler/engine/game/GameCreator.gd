extends Node

const SerializerGd           = preload("res://projects/Serialization/hierarchical_serializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")
const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")
const UnitCreationDataGd     = preload("res://engine/units/UnitCreationData.gd")
const FogOfWarGd             = preload("res://engine/level/FogOfWar.gd")

var _game : GameScene
var _levelLoader : LevelLoaderGd
var _currentLevelParent : Node


signal createFinished( error )


func initialize( gameScene : GameScene, currentLevelParent : Node ):
	_game = gameScene
	_currentLevelParent = currentLevelParent
	_levelLoader = LevelLoaderGd.new( gameScene )


func createFromModule( module : ModuleState, unitsCreationData : Array ) -> Error:
	assert( _game._module == null )
	_game.setCurrentModule( module )

	var result :Error = await _create( unitsCreationData )
	emit_signal( "createFinished", result )
	return result


func createFromFile( filePath : String ):
	await get_tree().process_frame

	var module : ModuleState = _game._module
	if not module:
		var result = _createNewModule( filePath )
		if result != OK:
			Debug.error( self, "Could not create module from %s" % filePath )
			return result
	else:
		assert( module.moduleMatches( filePath ) )
		module.loadFromFile( filePath )

	var result = await _create( [] )
	if result != OK:
		return result

	# deserialize player agent
	SerializerGd.new().deserialize( _game._module.getPlayerData(), _game )

	return result


func unloadCurrentLevel() -> Error:
	return await _levelLoader.unloadLevel()


func loadLevel( levelName : String, withState := true ) -> Error:
	var levelState = _game._module.loadLevelState( levelName, true ) \
		if withState \
		else null

	await _loadLevel( levelName, levelState )
	return OK


func _create( unitsCreationData : Array ) -> Error:
	await get_tree().process_frame

	assert( _game._module )
	assert( get_tree().paused )

	var module : ModuleState = _game._module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	await _loadLevel( levelName, levelState )

	var transition_zone_name = module.data().get_level_zone_transition( levelName )
	if not transition_zone_name.is_empty() and not unitsCreationData.is_empty():
		_createAndInsertUnits( unitsCreationData, transition_zone_name )

	return OK


func _loadLevel( levelName : String, levelState = null ):
	await get_tree().process_frame

	var filePath = _game._module.data().get_level_scene_path( levelName )
	if filePath.is_empty():
		return ERR_CANT_CREATE

	var result = await _levelLoader.loadLevel( filePath, _currentLevelParent )

	if result != OK:
		return result

	_game.currentLevel.applyFogToLevel( FogOfWarGd.TileType.Fogged )

	if levelState != null:
# warning-ignore:return_value_discarded
		SerializerGd.new().deserialize( levelState, _currentLevelParent )

	return OK


func _createNewModule( filePath : String ) -> Error:
	assert( _game._module == null )
	assert( _game.currentLevel == null )

	var module = ModuleState.createFromSaveFile( filePath )
	if not module:
		Debug.error( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		_game.setCurrentModule( module )
	return OK


func _createAndInsertUnits( playerUnitData : Array, transition_zone_name : String ):
	var playerUnits__ = _createPlayerUnits__( playerUnitData )
	_game.set_player_units( playerUnits__ )

	var unitNodes : Array = _game.get_player_units()

	var notAdded = LevelLoaderGd.insertPlayerUnits( unitNodes, _game.currentLevel, transition_zone_name )
	for unit in notAdded:
		Debug.info(self, "Unit '%s' not added to level" % unit.name)


func _createPlayerUnits__( unitsCreationData : Array ) -> Array[UnitBase]:
	var playerUnits__ :Array[UnitBase]= []
	for unitData in unitsCreationData:
		assert( unitData is UnitCreationDataGd )
		var fileName = _game._module.data().get_unit_scene_path( unitData.name )
		if fileName.is_empty():
			continue

		var unitNode__ : UnitBase = load( fileName ).instantiate()
		unitNode__.set_name( "player_%s" % [unitData.name] )

		playerUnits__.append( unitNode__ )
	return playerUnits__
