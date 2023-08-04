extends CharacterBody2D
class_name UnitBase


@export var _movement_speed            :float = 5.0

var requestedDirection                 := Vector2i()
var _currentDirection                  := Vector2i(): set = setCurrentDirection
@onready var _nameLabel                :Label = $"Name"
@onready var _pivot                    :Marker2D


signal predelete()
signal changedPosition()
signal moved( direction ) # Vector2i
signal clicked()


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _exit_tree():
	setCurrentDirection(Vector2())
	_pivot.position = Vector2()


func _physics_process(_delta):
	if _currentDirection or !requestedDirection:
		return

	assert( abs(requestedDirection.x) in [0, 1] )
	assert( abs(requestedDirection.y) in [0, 1] )

	var movementVector : Vector2 = _makeMovementVector( requestedDirection )
	assert( movementVector )

	if test_move( transform, movementVector ):
		return

	setCurrentDirection( requestedDirection )

	position += movementVector
	changedPosition.emit()

	var tween = create_tween()
	# TODO correct duration
	var duration = movementVector.length() / Constants.GRID_STEP.x / _movement_speed
	_pivot.position = -movementVector
	tween.tween_property( _pivot, ^'position', Vector2(0, 0), duration )
	tween.set_trans( Tween.TRANS_LINEAR ).set_ease( Tween.EASE_IN )
	tween.finished.connect(Callable(self, '_on_movement_tween_finished'))


func _on_movement_tween_finished():
	if _currentDirection:
		moved.emit(_currentDirection)
		setCurrentDirection(Vector2())


func _notification(what):
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		_pivot = $"Pivot"
	elif what == NOTIFICATION_PREDELETE:
		predelete.emit()
		Debug.updateVariable("Unit count", -1, true)


func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_LMB"):
		clicked.emit()


func die():
	queue_free()


func setNameLabel( newName ):
	_nameLabel.text = newName


func getIcon() -> Texture2D:
	return $"Pivot/Sprite2D".texture


func setCurrentDirection( direction : Vector2 ):
	_currentDirection = direction
	requestedDirection = Vector2()


func serialize():
	var dict := {
		"position" : position + _pivot.position,
		"moveDir" : _currentDirection,
		}
	return dict


func deserialize( saveDict : Dictionary ):
	set_position( Vector2(saveDict["position"]) )

	if saveDict.has('moveDir'):
		var direction : Vector2 = saveDict["moveDir"]
		if direction:
			requestedDirection = direction


func _makeMovementVector( direction : Vector2 ) -> Vector2:
	var x_add :float = direction.x if direction.x <= 0 else float(Constants.GRID_STEP.x)
	var x_target = int( (position.x + x_add) / Constants.GRID_STEP.x ) * Constants.GRID_STEP.x
	var x_diff = x_target - position.x

	var y_add :float = direction.y if direction.y <= 0 else float(Constants.GRID_STEP.y)
	var y_target = int( (position.y + y_add) / Constants.GRID_STEP.y ) * Constants.GRID_STEP.y
	var y_diff = y_target - position.y

	return Vector2(x_diff, y_diff)
