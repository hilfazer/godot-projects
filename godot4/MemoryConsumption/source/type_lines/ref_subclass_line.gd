@tool
extends "res://source/abstract_type_line.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = MyRef.new()
	return OK


func _destroy():
	objects.clear()


class MyRef extends RefCounted:
	pass
