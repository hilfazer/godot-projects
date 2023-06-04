extends Node2D

@export var nextScene: String = ""

func _ready():
	var param = SceneSwitcher.get_params(self)
	$"LineEditParams".text = param if param else ""


func _on_Switch_pressed():
	SceneSwitcher.switch_scene(nextScene)
