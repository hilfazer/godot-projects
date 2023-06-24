@tool
extends Area2D

@onready var _rectShape = $"CollisionShape2D".shape
@onready var _perimeter = $"Perimeter"


func _process(_delta):
	var x = _rectShape.size.x
	var y = _rectShape.size.y
	var points = _perimeter.points

	assert(points.size() == 5)
	points[0] = Vector2(-x, -y)
	points[1] = Vector2(-x, y)
	points[2] = Vector2(x, y)
	points[3] = Vector2(x, -y)
	points[4] = points[0]
	_perimeter.points = points
