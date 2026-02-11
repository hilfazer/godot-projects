extends Control

const SWITCH_TEXT = "switch_scene( %s : filepath )"
const SWITCH_TO_TEXT = "switch_scene( %s : PackedScene )"
const SWITCH_INTERACTIVE_TEXT = "switch_interactive( %s : filepath )"
const PARAM_META_KEY = "META"

@export var nextScene: String = ""
@export var defaultParamText: String = ""
@export var interactive_scene: String = ""

var paramFromSwitcher


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)
	paramFromSwitcher = SceneSwitcher.get_params(self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SWITCH_TEXT % nextScene
	$"VBoxButtons/SwitchTo".text = SWITCH_TO_TEXT % nextScene
	$"VBoxButtons/SwitchInteractive".text = SWITCH_INTERACTIVE_TEXT % interactive_scene
	$"VBoxParam/LineEditInput".text = defaultParamText
	$"VBoxParam/LineEditReceived".text = paramFromSwitcher if paramFromSwitcher else defaultParamText

	if has_meta(PARAM_META_KEY):
		var param = get_meta(PARAM_META_KEY)
		$"VBoxParam/LineEditReceivedMeta".text = param if param else defaultParamText


func switchPath():
	@warning_ignore("return_value_discarded")
	SceneSwitcher.switch_scene(nextScene, $"VBoxParam/LineEditInput".text, PARAM_META_KEY )


func switchPackedScene():
	var sceneNode = load(nextScene).instantiate()
	assert( sceneNode.paramFromSwitcher == null )
	var packedScene = PackedScene.new()
	@warning_ignore("return_value_discarded")
	packedScene.pack( sceneNode )
	sceneNode.free()
	var error = SceneSwitcher.switch_scene_to( packedScene, $"VBoxParam/LineEditInput".text, PARAM_META_KEY )
	assert(error == OK)


func switchInstancedScene():
	var metaName = "switchInstancedScene"
	var sceneNode = load(nextScene).instantiate()
	assert( sceneNode.paramFromSwitcher == null )

	@warning_ignore("return_value_discarded")
	SceneSwitcher.scene_set_as_current.connect(sceneNode._grabSceneParams, CONNECT_ONE_SHOT)
	@warning_ignore("return_value_discarded")
	SceneSwitcher.scene_set_as_current.connect( \
		sceneNode._retrieveMeta.bind(metaName), CONNECT_ONE_SHOT)

	var error = SceneSwitcher.switch_scene_to_instance( sceneNode, $"VBoxParam/LineEditInput".text, metaName )
	assert(error == OK)


func reloadScene():
	if SceneSwitcher.reload_current_scene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switch_interactive():
	var error = SceneSwitcher.switch_scene_interactive(interactive_scene, $"VBoxParam/LineEditInput".text )
	assert(error == OK)


func clear_scene():
	var error = await SceneSwitcher.clear_scene()
	assert( error == OK )


func _grabSceneParams():
	assert( self == get_tree().current_scene )
	paramFromSwitcher = SceneSwitcher.get_params(self)


func _retrieveMeta( meta : String ):
	var param = get_meta( meta ) if has_meta( meta ) else null
	$"VBoxParam/LineEditReceivedMeta".text = param if param else defaultParamText


func _retrieveMetaWithScene( _scene, meta : String ):
	_retrieveMeta( meta )
