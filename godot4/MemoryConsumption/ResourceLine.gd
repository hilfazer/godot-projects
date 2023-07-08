@tool
extends "res://abstract_type_line.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = Resource.new()
	return OK


func _destroy():
	objects.clear()
