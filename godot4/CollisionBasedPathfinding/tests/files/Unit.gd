extends CharacterBody2D

@export var MaxLength := 2.0 # speed

var _path := PackedVector2Array()
var _targetPointIdx := -1

signal selected()


func _physics_process(_delta):
	assert(_targetPointIdx < _path.size())

	if _targetPointIdx == -1:
		return

	var toMove = (_path[_targetPointIdx] - position).limit_length(MaxLength)
# warning-ignore:return_value_discarded
	move_and_collide(toMove)

	if position == _path[_targetPointIdx]:
		if _targetPointIdx + 1 == _path.size():
			setPath(PackedVector2Array())
		else:
			_targetPointIdx += 1


func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("unit_select"):
		emit_signal('selected')


func followPath( path2d : PackedVector2Array ):
	setPath(path2d)


func setPath( path : PackedVector2Array ):
	if path.size() < 2:
		_path = PackedVector2Array()
		_targetPointIdx = -1
	else:
		_path = path
		_targetPointIdx = 1
		position = path[0]
