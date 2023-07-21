extends Node


const SavingModuleGd         = preload("res://engine/SavingModule.gd")
const SerializerGd           = preload("res://projects/Serialization/hierarchical_serializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")
const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")
const UnitCreationDataGd     = preload("res://engine/units/UnitCreationData.gd")
const FogOfWarGd             = preload("res://engine/level/FogOfWar.gd")

var _game : Node
var _levelLoader : LevelLoaderGd
var _currentLevelParent : Node


signal createFinished( error )


func initialize( gameScene : Node, currentLevelParent : Node ):
	_game = gameScene
	_currentLevelParent = currentLevelParent
	_levelLoader = LevelLoaderGd.new( gameScene )


func createFromModule( module : SavingModuleGd, unitsCreationData : Array ) -> int:
	assert( _game._module == null )
	_game.setCurrentModule( module )

	var result = await _create( unitsCreationData )
	emit_signal( "createFinished", result )
	return result


func createFromFile( filePath : String ):
	await get_tree().idle_frame

	var module : SavingModuleGd = _game._module
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

# warning-ignore:return_value_discarded
	SerializerGd.new().deserialize( _game._module.getPlayerData(), _game._playerManager )

	return result


func unloadCurrentLevel():
	await _levelLoader.unloadLevel()


func loadLevel( levelName : String, withState := true ) -> int:
	var levelState = _game._module.loadLevelState( levelName, true ) \
		if withState \
		else null

	await _loadLevel( levelName, levelState )
	return OK


func _create( unitsCreationData : Array ) -> int:
	await get_tree().idle_frame

	assert( _game._module )
	assert( get_tree().paused )

	var module : SavingModuleGd = _game._module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	await _loadLevel( levelName, levelState )

	var entranceName = module.getLevelEntrance( levelName )
	if not entranceName.is_empty() and not unitsCreationData.is_empty():
		_createAndInsertUnits( unitsCreationData, entranceName )

	return OK


func _loadLevel( levelName : String, levelState = null ):
	await get_tree().idle_frame

	var filePath = _game._module.getLevelFilename( levelName )
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


func _createNewModule( filePath : String ) -> int:
	assert( _game._module == null )
	assert( _game.currentLevel == null )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.error( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		_game.setCurrentModule( module )
	return OK


func _createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits__ = _createPlayerUnits__( playerUnitData )
	_game._playerManager.setPlayerUnits( playerUnits__ )

	var unitNodes : Array = _game._playerManager.getPlayerUnits()

	var notAdded = _levelLoader.insertPlayerUnits( unitNodes, _game.currentLevel, entranceName )
	for unit in notAdded:
		Debug.info(self, "Unit '%s' not added to level" % unit.name)


func _createPlayerUnits__( unitsCreationData : Array ) -> Array:
	var playerUnits__ := []
	for unitData in unitsCreationData:
		assert( unitData is UnitCreationDataGd )
		var fileName = _game._module.getUnitFilename( unitData.name )
		if fileName.is_empty():
			continue

		var unitNode__ : UnitBase = load( fileName ).instantiate()
		unitNode__.set_name( "player_%s" % [unitData.name] )

		playerUnits__.append( unitNode__ )
	return playerUnits__
