extends RefCounted
class_name ModuleState

const ItemDbFactoryGd        = preload("res://engine/items/item_factory.gd")
const SerializerGd           = preload("res://projects/Serialization/hierarchical_serializer.gd")
const ProbeGd                = preload("res://projects/Serialization/probe.gd")
const SavedGameRes           = preload("res://projects/Serialization/save_game_file.gd")

const NameCurrentLevel       = "CurrentLevel"
const NamePlayerData         = "PlayerData"
const NameModule             = "Module"


var _serializer : SerializerGd = SerializerGd.new()
var _module_data : ModuleData: get = data


func _init( module_data :ModuleData, serializer :SerializerGd = null ) -> void:
	_module_data = module_data
	
	if not serializer:
		_serializer.user_data[NameModule] = _module_data.resource_path
		_serializer.user_data[NameCurrentLevel] = _module_data.starting_level_name
	else:
		_serializer = serializer


func saveToFile( save_path : String ) -> Error:
	assert( _serializer.user_data.get(NameModule) == _module_data.resource_path )

	var result :Error = _serializer.save_to_file( save_path )
	if result != OK:
		Debug.warn( self, "ModuleState: could not save to file %s" % save_path )

	return result


func loadFromFile( save_path : String ):
	assert( moduleMatches( save_path ) )

	_serializer.load_from_file( save_path )


func moduleMatches( save_file_path : String ) -> bool:
	@warning_ignore("static_called_on_instance")
	return extract_module_path( save_file_path ) == _module_data.resource_path


func deserialize_player_data( parent_node :Node ):
	assert(parent_node)
	var user_data = _serializer.user_data.get( NamePlayerData )
	_serializer.deserialize(user_data, parent_node)


func savePlayerData( player_agent : PlayerAgent ):
	var playerData = _serializer.serialize( player_agent )
	_serializer.user_data[NamePlayerData] = playerData


func getCurrentLevelName() -> String:
	assert( _serializer.user_data.get( NameCurrentLevel ) )
	return _serializer.user_data.get( NameCurrentLevel )


func saveLevel( level : LevelBase, makeCurrent : bool ):
	if not _module_data.level_names.has( level.file_name() ):
		Debug.warn( self,"ModuleState: module has no level named %s" % level.file_name())
		return

	if OS.has_feature("debug"):
		var probe : ProbeGd.Probe = ProbeGd.scan( level )
		for node in probe.nodes_not_instantiable:
			Debug.warn( self, "noninstantiable node: %s" %
				[ node.get_script().resource_path ] )
		for node in probe.nodes_no_matching_deserialize:
			Debug.warn( self, "node has no deserialize(): %s" %
				[ node.get_script().resource_path ] )

	_serializer.add_and_serialize( level.file_name(), level )

	if makeCurrent:
		_serializer.user_data[NameCurrentLevel] = level.file_name()


func loadLevelState( levelName : String, makeCurrent = true ):
	if not _module_data.level_names.has( levelName ):
		Debug.warn( self,"ModuleState: module has no level named %s" % levelName)
		return null

	var state = null
	if _serializer.has_key( levelName ):
		state = _serializer.get_serialized( levelName )

	if makeCurrent:
		_serializer.user_data[NameCurrentLevel] = levelName

	return state


func data() -> ModuleData:
	return _module_data


static func extract_module_path( save_file_path : String ) -> String:
	if not FileAccess.open( save_file_path, FileAccess.READ ):
		return ""

	var moduleFile := ""
	var state : SavedGameRes = ResourceLoader.load( save_file_path )
	if state.userDict.has(NameModule):
		moduleFile = state.userDict[NameModule]

	return moduleFile


static func createFromSaveFile( save_file_path : String ) -> ModuleState:
	var serializer : SerializerGd = SerializerGd.new()
	var loadResult = serializer.load_from_file( save_file_path )
	if loadResult != OK:
		Debug.warn( null,"ModuleState: could not create module from file %s" % save_file_path)
		return null

	var module_path = serializer.user_data.get(NameModule)
	var module_data :ModuleData = ModuleLoader.load_module(module_path)

	return null if not module_data else ModuleState.new(module_data, serializer)
