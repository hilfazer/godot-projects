@tool
extends "res://AbstractTypeLine.gd"


var arrays := []


func _create( count : int ) -> int:
	arrays.resize(count)
	for i in arrays.size():
		arrays[i] = Array()
	return OK


func _destroy():
	arrays.clear()
