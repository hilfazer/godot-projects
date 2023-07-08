@tool
extends "res://abstract_type_line.gd"


var dicts := []


func _create( count : int ) -> int:
	dicts.resize(count)
	for i in dicts.size():
		dicts[i] = Dictionary()
	return OK


func _destroy():
	dicts.clear()

