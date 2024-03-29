extends Node


signal scene_instanced(scene) # it won't be emitted if switch_scene_to_instance() was used
signal scene_set_as_current()
signal progress_changed(progress)
signal faded_in()
signal faded_out()
#TODO abort_switch signal that returns parameters

const FADE_IN := "fade_in"
const FADE_OUT := "fade_out"
const MSG_WRONG_META_TYPE := "Metadata key needs to be either null or String"
const MSG_PARAMS_VIA_META := "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s"
const MSG_NEW_SCENE_INVALID := "SceneSwitcher: New scene is invalid"
const MSG_GET_PARAMS_BLOCKED := "SceneSwitcher: Node %s can't receive scene parameters"
const MSG_NODE_NOT_A_SCENE := "New scene's node (%s) isn't a scene"
const MSG_CANT_CREATE_THREAD := "SceneSwitcher: Couldn't create a thread"

enum State { READY, PREPARING, SWITCHING }

@export var play_animations := true

@onready var _transition_player: AnimationPlayer = $"AnimationPlayer"
var _param_handler: IParamsHandler = NullHandler.new()

var _state: int = State.READY
var _scene_loader: SceneLoader


func switch_scene( scene_path: String, params = null, meta = null ) -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	assert(meta == null or meta is String) #,MSG_WRONG_META_TYPE)
	assert( _scene_loader == null )
	_scene_loader = SceneLoader.new(self, params, meta, "_node_from_packed_scene")

	var error = _scene_loader.start_load_from_path(scene_path)
	if error == ERR_CANT_CREATE:
		_abort_switch(MSG_CANT_CREATE_THREAD)
		return FAILED

	_state = State.PREPARING

	if play_animations:
		_transition_player.play(FADE_IN)
	return OK


func switch_scene_interactive( scene_path: String, params = null, meta = null ) -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	assert(meta == null or meta is String) #,MSG_WRONG_META_TYPE)
	assert(_scene_loader == null)
	_scene_loader = SceneLoader.new(self, params, meta, "_node_from_packed_scene")

	var error = _scene_loader.start_load_from_path_interactive(scene_path)
	if error == ERR_CANT_CREATE:
		_abort_switch(MSG_CANT_CREATE_THREAD)
		return FAILED

	_state = State.PREPARING

	if play_animations:
		_transition_player.play(FADE_IN)
	return OK


func switch_scene_to( packed_scene: PackedScene, params = null, meta = null ) -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	assert(meta == null or meta is String) #,MSG_WRONG_META_TYPE)

	if not play_animations:
		_state = State.SWITCHING
		call_deferred("_deferred_switch_scene", packed_scene, "_node_from_packed_scene", params, meta)
	else:
		_state = State.PREPARING
		_scene_loader = SceneLoader.new(self, params, meta, "_node_from_packed_scene")
		_scene_loader.set_source_packed_scene(packed_scene)
		_transition_player.play(FADE_IN)
	return OK


func switch_scene_to_instance( node: Node, params = null, meta = null ) -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	assert(meta == null or meta is String) #,MSG_WRONG_META_TYPE)
	assert(is_instance_valid(node))

	if not play_animations:
		_state = State.SWITCHING
		call_deferred("_deferred_switch_scene", node, "_return_argument", params, meta)
	else:
		_state = State.PREPARING
		_scene_loader = SceneLoader.new(self, params, meta, "_return_argument")
		_scene_loader.set_source_node(node)
		_transition_player.play(FADE_IN)
	return OK


func clear_scene() -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	assert( _scene_loader == null )

	_state = State.SWITCHING
	await get_tree().process_frame
	_param_handler = NullHandler.new()
	get_tree().current_scene.free()
	get_tree().current_scene = null
	_state = State.READY
	return OK


func reload_current_scene() -> Error:
	if not _state == State.READY:
		return ERR_BUSY

	var scene_filename = get_tree().current_scene.scene_file_path
	if scene_filename.is_empty():
		return ERR_CANT_CREATE

	assert( _scene_loader == null )

	if play_animations:
		_transition_player.play(FADE_IN)

	_scene_loader = SceneLoader.new(
			self, _param_handler.params, _param_handler.meta_key, "_node_from_packed_scene")
	var error : Error = _scene_loader.start_load_from_path(scene_filename)
	
	if error == OK:
		_state = State.PREPARING
	return error


# pass 'self' as the argument
func get_params( node: Node ):
	if node != _param_handler.scene:
		print(MSG_GET_PARAMS_BLOCKED % [node.name])
		return null

	if _param_handler.meta_key != null:
		print( MSG_PARAMS_VIA_META % [ node, node.name, _param_handler.meta_key ] )

	return _param_handler.params

#-------------------------------------------------------------------------------

func _on_preperation_done():
	if not _scene_loader.has_valid_data():
		_abort_switch(MSG_NEW_SCENE_INVALID)
		return

	assert(_state == State.PREPARING)
	_try_switching()


func _try_switching():
	assert(_state == State.PREPARING and _scene_loader != null)

	if _transition_player.current_animation == FADE_IN:
		return

	if _scene_loader.is_busy():
		return

	call_deferred(
			"_deferred_switch_scene",
			_scene_loader.release_scene_source(),
			_scene_loader.scene_extraction_func,
			_scene_loader.params,
			_scene_loader.meta)
	_state = State.SWITCHING
	_scene_loader = null


func _deferred_switch_scene( scene_source, node_extraction_func: String, params, meta ):
	assert(scene_source != null)
	assert(_state == State.SWITCHING)
	assert(_scene_loader == null)

	if scene_source is Node:
		assert(not scene_source.scene_file_path.is_empty()) #,MSG_NODE_NOT_A_SCENE % [scene_source.name])

	var new_scene: Node = call( node_extraction_func, scene_source )
	if not is_instance_valid(new_scene):
		_abort_switch(MSG_NEW_SCENE_INVALID)
		return      # if instancing a scene failed current_scene will not change

	if meta != null:
		new_scene.set_meta( meta, params )

	_param_handler = ParamsHandler.new( params, new_scene, meta )

	if not scene_source is Node:
		@warning_ignore("return_value_discarded")
		scene_instanced.emit( new_scene )

	if get_tree().current_scene:
		get_tree().current_scene.free()
	assert( get_tree().current_scene == null )

	# Make it a current scene between its "_enter_tree()" and "_ready()" calls
	@warning_ignore("return_value_discarded")
	new_scene.connect("tree_entered", \
		Callable(self, "_set_as_current").bind(new_scene), CONNECT_ONE_SHOT)

	# Add it to the active scene, as child of root
	$"/root".add_child( new_scene )
	assert( $"/root".has_node( new_scene.get_path() ) )
	if play_animations:
		_transition_player.play(FADE_OUT)
	_state = State.READY


func _abort_switch( message: String ) -> void:
	if message:
		print(message, ". Scene switch aborted")

	if play_animations:
		_transition_player.seek(0, true)
		_transition_player.stop()
	_state = State.READY
	_scene_loader = null


func _on_progress_changed(progress) -> void:
	@warning_ignore("return_value_discarded")
	progress_changed.emit(progress)


func _set_as_current( scene: Node ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	@warning_ignore("return_value_discarded")
	scene_set_as_current.emit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == FADE_IN:
		@warning_ignore("return_value_discarded")
		faded_in.emit()
		if _state == State.PREPARING:
			_try_switching()
	elif anim_name == FADE_OUT:
		@warning_ignore("return_value_discarded")
		faded_out.emit()


static func _node_from_packed_scene( packed_scene: PackedScene ) -> Node:
	return packed_scene.instantiate() if packed_scene.can_instantiate() else null


static func _return_argument( node: Node ) -> Node:
	return node

#-------------------------------------------------------------------------------

class IParamsHandler extends RefCounted:
	pass


class NullHandler extends IParamsHandler:
	var params = null
	var scene = null
	var meta_key = null


class ParamsHandler extends IParamsHandler:
	var params
	var scene: Node
	var meta_key   # String or null


	func _init( parameters, scene_node: Node, metadata_key ):
		assert(scene_node)
		params = parameters
		scene = scene_node
		if metadata_key == null:
			return
		else:
			assert(metadata_key is String) #,MSG_WRONG_META_TYPE)
			assert( scene.has_meta( metadata_key ) )
			meta_key = metadata_key


class SceneLoader extends RefCounted:
	signal loading_done()
	signal progress_changed(progress)

	var params = null
	var meta = null
	var scene_extraction_func: String
	var _packed_scene: PackedScene
	var _scene__: Node
	var _loader_thread: Thread


	func _init(switcher, params_, meta_, scene_extraction_func_: String):
		assert(scene_extraction_func_ != "")
		params = params_
		meta = meta_
		scene_extraction_func = scene_extraction_func_
		@warning_ignore("return_value_discarded")
		connect("loading_done", Callable(switcher, "_on_preperation_done").bind(), CONNECT_ONE_SHOT)
		@warning_ignore("return_value_discarded")
		connect("progress_changed", Callable(switcher, "_on_progress_changed"))


	func _notification(what):
		if what == NOTIFICATION_PREDELETE and _scene__:
			assert(not _scene__.is_inside_tree())
			_scene__.free()


	func start_load_from_path(scene_path: String) -> Error:
		_loader_thread = Thread.new()
		var error : Error = _loader_thread.start( \
			Callable(self, "_packed_scene_from_path").bind(scene_path) )
			
		if error != OK:
			_loader_thread = null
		return error


	func start_load_from_path_interactive(scene_path: String) -> Error:
		_loader_thread = Thread.new()
		var error : Error = _loader_thread.start( \
			Callable(self, "_packed_scene_from_path_interactive").bind(scene_path) )
			
		if error != OK:
			_loader_thread = null
		return error


	func is_busy() -> bool:
		return _loader_thread and _loader_thread.is_started()


	func has_valid_data() -> bool:
		return _scene__ != null or _packed_scene != null


	func release_scene_source():
		if _scene__:
			var s = _scene__
			_scene__ = null
			return s
		else:
			return _packed_scene if _packed_scene else null


	func set_source_node(node: Node):
		assert(node.scene_file_path != "") #,MSG_NODE_NOT_A_SCENE % [node.name])
		assert(_scene__ == null and _packed_scene == null)
		_scene__ = node


	func set_source_packed_scene(packed_scene: PackedScene):
		assert(packed_scene != null)
		assert(_scene__ == null and _packed_scene == null)
		_packed_scene = packed_scene


	func _packed_scene_from_path( path: String ) -> void:
		call_deferred("_finalize_load", ResourceLoader.load( path ) )


	func _packed_scene_from_path_interactive( path: String ) -> void:
		var error : Error = ResourceLoader.load_threaded_request( path )
		assert(error == OK)
		
		var progress := []
		
		var res: PackedScene = null

		while true: #iterate until we have a resource
			# Update progress bar, use call deferred, which routes to main thread.
			var status = ResourceLoader.load_threaded_get_status(path, progress)
			@warning_ignore("return_value_discarded")
			progress_changed.emit(progress[0])


			# If OK, then load another one. If EOF, it' s done. Otherwise there was an error.
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				# Loading done, fetch resource.
				res = ResourceLoader.load_threaded_get(path)
				@warning_ignore("return_value_discarded")
				progress_changed.emit(100.0)
				break
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				# Not OK, there was an error.
				print("There was an error loading")
				break
			elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("Invalid resource")
				break

		call_deferred("_finalize_load", res)


	func _finalize_load( packed_scene_: PackedScene ):
		_loader_thread.wait_to_finish()
		_packed_scene = packed_scene_
		@warning_ignore("return_value_discarded")
		loading_done.emit()
