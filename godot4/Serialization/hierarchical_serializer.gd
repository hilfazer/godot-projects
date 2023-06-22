extends RefCounted

const NodeGuardGd            = preload("./node_guard.gd")
const SaveGameFileGd         = preload("./save_game_file.gd")

const SERIALIZE              = "serialize"
const DESERIALIZE            = "deserialize"
const POST_DESERIALIZE       = "post_deserialize"
const IS_SERIALIZABLE        = "is_serializable"

enum _Index { NAME, SCENE, OWN_DATA, FIRST_CHILD }

var user_data := {}

var _version : String = "0.0.0"
var _nodes_data := {}
var _resource_extension := ".tres" if OS.has_feature("debug") else ".res"

var _is_serializable_fn : Callable
var _is_serializable_obj : RefCounted


func _init():
	set_default_is_node_serializable()


func add_and_serialize( key : String, node : Node ) -> bool:
	var result : Array = serialize( node )
	if result != []:
		_nodes_data[ key ] = result
		return true
	else:
		return false


func add_serialized( key : String, serialized_branch : Array ) -> void:
	assert( serialized_branch != [] )
	_nodes_data[ key ] = serialized_branch


func remove_serialized( key : String ) -> bool:
	return _nodes_data.erase( key )


func has_key( key : String ) -> bool:
	return _nodes_data.has( key )


func get_and_deserialize( key : String, parent : Node ) -> NodeGuardGd:
	assert( has_key( key ) )
	return deserialize( get_serialized( key ), parent )


func get_serialized( key : String ) -> Array:
	assert( has_key( key ) )
	return _nodes_data[key]


func get_keys() -> PackedStringArray:
	return PackedStringArray( _nodes_data.keys() )


func get_version() -> String:
	return _version


func set_default_is_node_serializable():
	_is_serializable_fn = Callable( self, "_is_serializable" )
	_is_serializable_obj = null


func set_custom_is_node_serializable( functor : RefCounted ):
	set_default_is_node_serializable()

	if functor == null:
		return
	else:
		assert( is_instance_valid( functor ) )
		assert( functor.has_method( IS_SERIALIZABLE ) )
		var fn := Callable( functor, IS_SERIALIZABLE )
		_is_serializable_fn = fn
		_is_serializable_obj = functor


func save_to_file( filepath : String ) -> int:
	var base_directory : String = filepath.get_base_dir()

	if not filepath.is_valid_filename() and base_directory.is_empty():
		print("not a valid filepath")
		return ERR_CANT_CREATE

	var dir = DirAccess.open( base_directory )
	if not dir:
		var error = dir.make_dir_recursive( base_directory )
		if error != OK:
			print( "could not create a directory" )
			return error

	var state_to_save = SaveGameFileGd.new()

	var ver = ProjectSettings.get_setting("application/config/version")
	if typeof(ver) == TYPE_STRING:
		_version = ver

	state_to_save.version = _version
	state_to_save.nodesDict = _nodes_data
	state_to_save.userDict = user_data

	var path_to_save = filepath
	if not filepath.get_extension() in ResourceSaver.get_recognized_extensions(state_to_save):
		path_to_save += _resource_extension

	var error := ResourceSaver.save( state_to_save, path_to_save )
	if error != OK:
		print( "could not save a Resource" )
		return error

	return OK


func load_from_file( filepath : String ) -> int:
	var path_to_load = filepath
	if "." + filepath.get_extension() != _resource_extension:
		path_to_load += _resource_extension

	if not FileAccess.file_exists( path_to_load ):
		print( "file does not exist" )
		return ERR_DOES_NOT_EXIST

	var loaded_state : SaveGameFileGd = load( path_to_load )
	_version = loaded_state.version
	_nodes_data = loaded_state.nodesDict
	user_data = loaded_state.userDict
	return OK


# returns an Array with: node name, scene, node's own data, serialized children (if any)
func serialize( node : Node ) -> Array:
	assert( is_instance_valid( node ) )
	var data := [
		node.name,
		node.scene_file_path,
		node.serialize() if _is_serializable_fn.call( node ) else null
	]

	for child in node.get_children():
		var child_data = serialize( child )
		if not child_data.is_empty():
			data.append( child_data )

	if data[ _Index.OWN_DATA ] == null and data.size() <= _Index.FIRST_CHILD:
		return []
	else:
		return data


# parent can be null
func deserialize( data : Array, parent : Node ) -> NodeGuardGd:
	assert( not data.is_empty() )
	var node_name  = data[_Index.NAME]
	var scene_file = data[_Index.SCENE]
	var own_data   = data[_Index.OWN_DATA]

	var node : Node
	if not parent:
		if !scene_file.is_empty():
			node = load( scene_file ).instantiate()
			node.name = node_name
	else:
		node = parent.get_node_or_null( NodePath(node_name) )
		if not node:
			if !scene_file.is_empty():
				node = load( scene_file ).instantiate()
				parent.add_child( node )
				assert( parent.is_ancestor_of( node ) )
				node.name = node_name

	if not node:
		return NodeGuardGd.new()# node didn't exist and could not be created by serializer

	if own_data != null and node.has_method( DESERIALIZE ):
		# warning-ignore:return_value_discarded
		node.deserialize( own_data )

	for child_idx in range( _Index.FIRST_CHILD, data.size() ):
		# warning-ignore:return_value_discarded
		deserialize( data[child_idx], node )

	if node.has_method( POST_DESERIALIZE ):
		node.post_deserialize()

	return NodeGuardGd.new( node )


static func _is_serializable( node : Node ) -> bool:
	return node.has_method( SERIALIZE ) and node.has_method( DESERIALIZE )

