@tool
extends "res://AbstractTypeLine.gd"


var poolInts := PackedInt32Array()


func _create( count : int ) -> int:
	poolInts.resize(count)
	for i in poolInts.size():
		poolInts[i] = 3
	return OK


func _destroy():
	poolInts.resize(0)


func _compute():
	var _sum := 0
	for i in poolInts.size():
		_sum += poolInts[i]

