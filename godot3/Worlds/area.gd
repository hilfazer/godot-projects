extends Area2D

export var _circle_color: Color

var _collide_color: = Color(Color.green)
var _no_collide_color: = Color(Color.whitesmoke)

onready var circle_shape: CircleShape2D = $'CollisionShape2D'.shape


func _physics_process(_delta):
	if get_overlapping_areas().size() == 0:
		$'ColorRect'.color = _no_collide_color
	else:
		$'ColorRect'.color = _collide_color


func _draw():
	draw_circle($'CollisionShape2D'.position, circle_shape.radius, _circle_color)
