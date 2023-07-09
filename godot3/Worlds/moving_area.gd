extends Node

export var speed: float = 100

onready var _area: Area2D = $'Area2D'
onready var _target1: Position2D = $'Position2D'
onready var _target2: Position2D = $'Position2D2'


func _ready():
	$'Tween'.connect("tween_completed", self, '_on_target_reached')
	_move_area(_target1)


func _on_target_reached(_obj, _key):
	var target = _target2 if _obj.position == _target1.position else _target1
	_move_area(target)


func _calculate_transition_time() -> float:
	return _target1.position.distance_to(_target2.position) / speed


func _move_area(target: Position2D):
	var time: float = _calculate_transition_time()
	$'Tween'.interpolate_property(_area, 'position', \
			_area.global_position, target.global_position, time, \
			Tween.TRANS_CUBIC, Tween.EASE_IN )
	$'Tween'.start()
