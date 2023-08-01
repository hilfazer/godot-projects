extends "res://resources/base_resource.gd"
class_name InheritedResource

@export var inherited_var := ".."


@export var v = 0:
	set(v):
		foo()

func foo():
	pass
