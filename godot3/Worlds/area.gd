extends Area2D

var _collide_color: = Color(Color.green)
var _no_collide_color: = Color(Color.whitesmoke)


func _physics_process(_delta):
	if get_overlapping_areas().size() == 0:
		$'ColorRect'.color = _no_collide_color
	else:
		$'ColorRect'.color = _collide_color
