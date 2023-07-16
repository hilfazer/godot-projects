@tool
extends "res://source/abstract_type_line.gd"


var floats := {}


func _create( count : int ) -> int:
	for i in count:
		floats[float(i)] = true
	return OK


func _destroy():
	floats.clear()
