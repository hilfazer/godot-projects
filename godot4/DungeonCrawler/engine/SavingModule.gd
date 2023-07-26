extends "./Module.gd"
#TODO remove SavingModule, make a new class that doesn't inherit Module.gd

const SerializerGd           = preload("res://projects/Serialization/hierarchical_serializer.gd")
const ProbeGd                = preload("res://projects/Serialization/Probe.gd")
const SavedGameRes           = preload("res://projects/Serialization/save_game_file.gd")
const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")
const SelfFilename           = "res://engine/SavingModule.gd"

# JSON keys
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerData         = "PlayerData"


var _serializer : SerializerGd = SerializerGd.new()


func _init( moduleData, moduleFilename : String, serializer = null ):
	super( moduleData, moduleFilename )

	if serializer:
		_serializer = serializer
	else:
		_serializer.user_data[NameModule] = moduleFilename
		_serializer.user_data[NameCurrentLevel] = getStartingLevelName()


func saveToFile( saveFilename : String ) -> int:
	assert( _serializer.user_data.get(NameModule) == _moduleFilename )

	var result = _serializer.save_to_file( saveFilename )
	if result != OK:
		Debug.warn( self, "SavingModule: could not save to file %s" % saveFilename )

	return result


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )

	_serializer.load_from_file( saveFilename )


func saveLevel( level : LevelBase, makeCurrent : bool ):
	if not _data.LevelNames.has( level.name ):
		Debug.warn( self,"SavingModule: module has no level named %s" % level.name)
		return

	if OS.has_feature("debug"):
		var probe : ProbeGd.Probe = ProbeGd.scan( level )
		for node in probe.nodes_not_instantiable:
			Debug.warn( self, "noninstantiable node: %s" %
				[ node.get_script().resource_path ] )
		for node in probe.nodes_no_matching_deserialize:
			Debug.warn( self, "node has no deserialize(): %s" %
				[ node.get_script().resource_path ] )

	_serializer.add_and_serialize( level.name, level )

	if makeCurrent:
		_serializer.user_data[NameCurrentLevel] = level.name


func loadLevelState( levelName : String, makeCurrent = true ):
	if not _data.LevelNames.has( levelName ):
		Debug.warn( self,"SavingModule: module has no level named %s" % levelName)
		return null

	var state = null
	if _serializer.has_key( levelName ):
		state = _serializer.get_serialized( levelName )

	if makeCurrent:
		_serializer.user_data[NameCurrentLevel] = levelName

	return state


func savePlayerData( playerAgent : PlayerAgentGd ):
	var playerData = _serializer.serialize( playerAgent )
	_serializer.user_data[NamePlayerData] = playerData


func moduleMatches( saveFilename : String ) -> bool:
	@warning_ignore("static_called_on_instance")
	return extractModuleFilename( saveFilename ) == _moduleFilename


func getCurrentLevelName() -> String:
	assert( _serializer.user_data.get( NameCurrentLevel ) )
	return _serializer.user_data.get( NameCurrentLevel )


func getPlayerData():
	return _serializer.user_data.get( NamePlayerData )


static func extractModuleFilename( saveFilename : String ) -> String:
	if not FileAccess.open( saveFilename, FileAccess.READ ):
		return ""

	var moduleFile := ""
	var state : SavedGameRes = ResourceLoader.load( saveFilename )
	if state.userDict.has(NameModule):
		moduleFile = state.userDict[NameModule]

	return moduleFile
	# TODO: cache files or make module filename quickly accessible


static func createFromSaveFile( saveFilename : String ):
	var serializer : SerializerGd = SerializerGd.new()
	var loadResult = serializer.load_from_file( saveFilename )
	if loadResult != OK:
		Debug.warn( null,"SavingModule: could not create module from file %s" % saveFilename)
		return null

	var moduleFilename = serializer.user_data.get(NameModule)
	var moduleNode = null

	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData: ModuleDataGd = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename, serializer)

	return moduleNode

