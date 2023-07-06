@tool
extends "res://AbstractTypeLine.gd"


var floats := []


func _create( count : int ) -> int:
	floats.resize(count)
	for i in count:
		floats[i] = 2.2
	return OK


func _destroy():
	floats.clear()
