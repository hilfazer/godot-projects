@tool
extends "res://AbstractTypeLine.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = MyRes.new()
	return OK


func _destroy():
	objects.clear()


class MyRes extends Resource:
	pass
