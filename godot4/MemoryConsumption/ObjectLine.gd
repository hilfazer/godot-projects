@tool
extends "res://abstract_type_line.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = ClassDB.instantiate("Object")
	return OK


func _destroy():
	for i in objects.size():
		objects[i].free()
	objects.clear()

