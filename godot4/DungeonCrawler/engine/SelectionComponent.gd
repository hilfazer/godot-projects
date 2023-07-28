@tool
extends Area2D

@onready var _rect_shape :RectangleShape2D = $"CollisionShape2D".shape
@onready var _perimeter  :Line2D = $"Perimeter"


func _process( _delta :float ):
	var x = _rect_shape.size.x
	var y = _rect_shape.size.y
	var points = _perimeter.points

	assert(points.size() == 5)
	points[0] = Vector2(-x, -y)
	points[1] = Vector2(-x, y)
	points[2] = Vector2(x, y)
	points[3] = Vector2(x, -y)
	points[4] = points[0]
	_perimeter.points = points
