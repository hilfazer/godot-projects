extends Node

var _tween: Tween 

@export var speed: float = 100

@onready var _area: Area2D = $'Area2D'
@onready var _target1: Marker2D = $'Target1'
@onready var _target2: Marker2D = $'Target2'


func _ready():
	_move_area(_target1)


func _exit_tree():
	if _tween:
		_tween.pause()

	_area.position = _target2.position
	request_ready()


func _on_target_reached() -> void:
	var target = _target2 if _area.position == _target1.position else _target1
	_move_area(target)


func _calculate_transition_time(target: Marker2D) -> float:
	return _area.position.distance_to(target.position) / speed


func _move_area(target: Marker2D) -> void:
	var time: float = _calculate_transition_time(target)
	_tween = create_tween()
	_tween.finished.connect(Callable(self, '_on_target_reached'))
	_tween.tween_property(_area, 'position', target.global_position, time)
