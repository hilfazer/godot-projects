extends AgentBase


var _pressedDirections :PackedByteArray = [0, 0, 0, 0]


func _ready():
	var parent = get_parent()
	if parent is UnitBase:
		call_deferred( 'addUnit', parent )


func _physics_process( _delta ):
	var direction := Vector2(
		_pressedDirections[3] - _pressedDirections[2], _pressedDirections[1] - _pressedDirections[0]
		)
	if !direction:
		return

	for unit in _unitsInTree:
		unit.requestedDirection = direction


func _unhandled_input(event):
	if event.is_action_pressed("gameplay_up"):
		_pressedDirections[0] = 1
	elif event.is_action_pressed("gameplay_down"):
		_pressedDirections[1] = 1
	elif event.is_action_pressed("gameplay_left"):
		_pressedDirections[2] = 1
	elif event.is_action_pressed("gameplay_right"):
		_pressedDirections[3] = 1
	elif event.is_action_released("gameplay_up"):
		_pressedDirections[0] = 0
	elif event.is_action_released("gameplay_down"):
		_pressedDirections[1] = 0
	elif event.is_action_released("gameplay_left"):
		_pressedDirections[2] = 0
	elif event.is_action_released("gameplay_right"):
		_pressedDirections[3] = 0
	else:
		return

	get_viewport().set_input_as_handled()

