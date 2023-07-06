@tool
extends "res://AbstractTypeLine.gd"


var floats := {}


func _create( count : int ) -> int:
	for i in count:
		floats[float(i)] = true
	return OK


func _destroy():
	floats.clear()
