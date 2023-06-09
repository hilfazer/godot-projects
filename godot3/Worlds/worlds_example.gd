extends Node

const MovingAreaGd = preload("res://moving_area.gd")

onready var _area1: MovingAreaGd = $'MovingArea1'
onready var _area2: MovingAreaGd = $'MovingArea2'
onready var _area3: MovingAreaGd = $'ViewportContainer/Viewport/MovingArea3'
onready var _subviewport: Viewport = $'ViewportContainer/Viewport'


func _on_ButtonMoveArea1_pressed():
	if _area1.get_viewport().world_2d == get_viewport().world_2d:
		remove_child(_area1)
		_subviewport.add_child(_area1)
	else:
		_subviewport.remove_child(_area1)
		add_child(_area1)


func _on_CheckButton_toggled(button_pressed):
	if button_pressed and not _area1.is_inside_tree():
		add_child(_area1)
	elif not button_pressed and _area1.is_inside_tree():
		_area1.get_parent().remove_child(_area1)
