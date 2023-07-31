extends RefCounted
class_name ModuleState

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")
const SerializerGd           = preload("res://projects/Serialization/hierarchical_serializer.gd")
const ProbeGd                = preload("res://projects/Serialization/Probe.gd")
const SavedGameRes           = preload("res://projects/Serialization/save_game_file.gd")

const NameCurrentLevel       = "CurrentLevel"
const NamePlayerData         = "PlayerData"
const NameModule             = "Module"


var _serializer : SerializerGd = SerializerGd.new()
var _module_data : ModuleData


func _init( module_data :ModuleData ) -> void:
	_module_data = module_data
	_serializer.user_data[NameModule] = _module_data.resource_path
	_serializer.user_data[NameCurrentLevel] = _module_data.starting_level_name


func saveToFile( save_path : String ) -> Error:
	assert( _serializer.user_data.get(NameModule) == _module_data.resource_path )

	var result :Error = _serializer.save_to_file( save_path )
	if result != OK:
		Debug.warn( self, "SavingModule: could not save to file %s" % save_path )

	return result


func loadFromFile( save_path : String ):
	assert( moduleMatches( save_path ) )

	_serializer.load_from_file( save_path )


func moduleMatches( saveFilename : String ) -> bool:
	@warning_ignore("static_called_on_instance")
	return extractModuleFilename( saveFilename ) == _module_data.resource_path


func getPlayerData():
	return _serializer.user_data.get( NamePlayerData )


func savePlayerData( player_agent : PlayerAgent ):
	var playerData = _serializer.serialize( player_agent )
	_serializer.user_data[NamePlayerData] = playerData


func getCurrentLevelName() -> String:
	assert( _serializer.user_data.get( NameCurrentLevel ) )
	return _serializer.user_data.get( NameCurrentLevel )


func saveLevel( level : LevelBase, makeCurrent : bool ):
	if not _module_data.LevelNames.has( level.name ):
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
	if not _module_data.LevelNames.has( levelName ):
		Debug.warn( self,"SavingModule: module has no level named %s" % levelName)
		return null

	var state = null
	if _serializer.has_key( levelName ):
		state = _serializer.get_serialized( levelName )

	if makeCurrent:
		_serializer.user_data[NameCurrentLevel] = levelName

	return state


func data() -> ModuleData:
	return _module_data


static func extractModuleFilename( saveFilename : String ) -> String:
	if not FileAccess.open( saveFilename, FileAccess.READ ):
		return ""

	var moduleFile := ""
	var state : SavedGameRes = ResourceLoader.load( saveFilename )
	if state.userDict.has(NameModule):
		moduleFile = state.userDict[NameModule]

	return moduleFile


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
		var moduleData: ModuleData = load(moduleFilename).new()
#		if verify( moduleData ):
#			moduleNode = new(moduleData, moduleFilename, serializer)

	return moduleNode
