## used to selet multiple units with mouse cursor
extends CanvasLayer

const MinimumDiagonal = 20

var startv := Vector2()
var endv := Vector2()
var is_dragging := false

@onready var rectd :ColorRect = $"ColorRect"


signal area_selected( rect2 )


func _ready():
	_drawArea(Rect2())


func _unhandled_input(event):
	if not event is InputEventMouse:
		return

	var mouseposGlobal = rectd.get_global_mouse_position()

	if event.is_action_pressed('ui_LMB'):
		startv = mouseposGlobal
		is_dragging = true

	if is_dragging:
		endv = mouseposGlobal
		@warning_ignore("static_called_on_instance")
		_drawArea(_makeRect( startv, endv ))

	if event.is_action_released('ui_LMB'):
		if startv.distance_to(mouseposGlobal) > MinimumDiagonal:
			endv = mouseposGlobal
			is_dragging = false
			_drawArea(Rect2())
			@warning_ignore("static_called_on_instance")
			area_selected.emit( _makeRect( startv, endv ) )
		else:
			is_dragging = false
			_drawArea(Rect2())


func _drawArea( rect : Rect2 ):
	rectd.size = rect.size
	rectd.position = rect.position


static func _makeRect( start : Vector2, end : Vector2 ):
	var pos  = Vector2( min(start.x, end.x), min(start.y, end.y) )
	var size = Vector2(abs(start.x - end.x), abs(start.y - end.y))
	return Rect2( pos, size )
