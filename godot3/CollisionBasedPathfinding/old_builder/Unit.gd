extends KinematicBody2D

export var MaxLength := 2.0 # speed

var _path := PoolVector2Array()
var _targetPointIdx := -1

export (int) var speed = 200
export (bool) var move_with_keyboard = false

var velocity = Vector2()


signal selected()


func _physics_process(_delta):
	if move_with_keyboard:
		get_input()
		velocity = move_and_slide(velocity)
		return

	assert(_targetPointIdx < _path.size())

	if _targetPointIdx == -1:
		return

	var toMove = (_path[_targetPointIdx] - position).clamped(MaxLength)
# warning-ignore:return_value_discarded
	move_and_collide(toMove)

	if position == _path[_targetPointIdx]:
		if _targetPointIdx + 1 == _path.size():
			setPath(PoolVector2Array())
		else:
			_targetPointIdx += 1


func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("unit_select"):
		emit_signal('selected')


func followPath( path2d : PoolVector2Array ):
	setPath(path2d)


func setPath( path : PoolVector2Array ):
	if path.size() < 2:
		_path = PoolVector2Array()
		_targetPointIdx = -1
	else:
		_path = path
		_targetPointIdx = 1
		position = path[0]


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
