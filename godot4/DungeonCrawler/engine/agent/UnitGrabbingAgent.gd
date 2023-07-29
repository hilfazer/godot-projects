extends AgentBase


var _direction := Vector2.ZERO

func _ready():
	var parent = get_parent()
	if parent is UnitBase:
		addUnit.call_deferred(parent)


func _physics_process( _delta ):
	if _direction != Vector2.ZERO:
		for unit in _unitsInTree:
			unit.requestedDirection = Vector2i(_direction)


func _unhandled_input(event):
	if 		event.is_action_pressed("move_up") or \
			event.is_action_pressed("move_down") or \
			event.is_action_pressed("move_left") or \
			event.is_action_pressed("move_right") or \
			event.is_action_released("move_up") or \
			event.is_action_released("move_down") or \
			event.is_action_released("move_left") or \
			event.is_action_released("move_right"):
		_direction = \
			Input.get_vector('move_left', 'move_right', 'move_up', 'move_down').snapped(Vector2.ONE)
	else:
		return

	get_viewport().set_input_as_handled() 
