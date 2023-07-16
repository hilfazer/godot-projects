@tool
extends "res://source/abstract_type_line.gd"


var ints := []


func _create( count : int ) -> int:
	ints.resize(count)
	for i in ints.size():
		ints[i] = 3
	return OK


func _destroy():
	ints.clear()
