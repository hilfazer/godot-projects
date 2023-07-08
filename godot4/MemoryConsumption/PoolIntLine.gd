@tool
extends "res://AbstractTypeLine.gd"


var packed_ints := PackedInt64Array()


func _create( count : int ) -> int:
	packed_ints.resize(count)
	for i in packed_ints.size():
		packed_ints[i] = 3
	return OK


func _destroy():
	packed_ints.resize(0)
