extends AgentBase


var _pressedDirections :PackedByteArray = [0, 0, 0, 0]


func _ready():
	var parent = get_parent()
	if parent is UnitBase:
		addUnit.call_deferred(parent)


func _physics_process( _delta ):
	var direction := Vector2(
		_pressedDirections[3] - _pressedDirections[2], _pressedDirections[1] - _pressedDirections[0]
		)
	if !direction:
		return

	for unit in _unitsInTree:
		unit.requestedDirection = direction


func _unhandled_input(event):
	if event.is_action_pressed("move_up"):
		_pressedDirections[0] = 1
	elif event.is_action_pressed("move_down"):
		_pressedDirections[1] = 1
	elif event.is_action_pressed("move_left"):
		_pressedDirections[2] = 1
	elif event.is_action_pressed("move_right"):
		_pressedDirections[3] = 1
	elif event.is_action_released("move_up"):
		_pressedDirections[0] = 0
	elif event.is_action_released("move_down"):
		_pressedDirections[1] = 0
	elif event.is_action_released("move_left"):
		_pressedDirections[2] = 0
	elif event.is_action_released("move_right"):
		_pressedDirections[3] = 0
	else:
		return

	get_viewport().set_input_as_handled()

