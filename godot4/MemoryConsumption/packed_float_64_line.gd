@tool
extends "res://abstract_type_line.gd"


var floats := PackedFloat64Array()


func _create( count : int ) -> int:
	floats.resize(count)
	for i in count:
		floats[i] = 2.2
	return OK


func _destroy():
	floats.clear()
