extends Node


func _ready():
	var _q :Node2D = $'.'	# runtime error if the value doesn't inherit Node2D


func implicit_type():
	#var s := return_variant()
	pass


func return_variant():
	return 3
