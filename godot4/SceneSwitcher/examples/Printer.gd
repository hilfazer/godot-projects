extends Node


@onready var _play_animations_button: CheckButton = $"HBoxContainer/CheckButtonPlay"
@onready var _progress_bar: ProgressBar = $"HBoxContainer/ProgressBar"


func _ready():
	@warning_ignore("return_value_discarded")
	SceneSwitcher.connect("scene_instanced", Callable(self, "onInstanced"))
	@warning_ignore("return_value_discarded")
	SceneSwitcher.connect("scene_set_as_current", Callable(self, "onCurrentChanged"))
	@warning_ignore("return_value_discarded")
	SceneSwitcher.connect("progress_changed", Callable(_progress_bar, "set_value"))
	@warning_ignore("return_value_discarded")
	SceneSwitcher.connect("faded_in", Callable(self, "on_faded_in"))
	@warning_ignore("return_value_discarded")
	SceneSwitcher.connect("faded_out", Callable(self, "on_faded_out"))

	SceneSwitcher.play_animations = _play_animations_button.button_pressed


func onInstanced( scene ):
	var sceneFilename = scene.scene_file_path if scene.scene_file_path else "no filename"
	print( "Scene %s [%s] instanced" % [scene, sceneFilename] )
	scene.connect("tree_entered", Callable(self, "onEntered").bind(scene), CONNECT_ONE_SHOT)
	scene.connect("ready", Callable(self, "onReady").bind(scene), CONNECT_ONE_SHOT)


func onEntered( scene ):
	var sceneFilename = scene.scene_file_path if scene.scene_file_path else "no filename"
	print( "Scene %s [%s] has entered the tree" % [scene, sceneFilename] )


func onCurrentChanged():
	var sceneFilename = get_tree().current_scene.scene_file_path \
		if get_tree().current_scene.scene_file_path else "no filename"
	print( "Scene %s [%s] is a current scene" % [get_tree().current_scene, sceneFilename] )


func onReady( scene ):
	var sceneFilename = scene.scene_file_path if scene.scene_file_path else "no filename"
	print( "Scene %s [%s] is ready" % [scene, sceneFilename] )


func on_faded_in():
	print("Faded in")


func on_faded_out():
	print("Faded out")
	Node.print_orphan_nodes()


func _on_ButtonPrintStray_pressed():
	Node.print_orphan_nodes()


func _on_CheckButtonPlay_toggled(button_pressed):
	SceneSwitcher.play_animations = button_pressed
