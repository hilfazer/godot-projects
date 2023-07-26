extends Node2D


func _enter_tree() -> void:
	var child = MoreDerived.new()
	add_child(child)


class Base extends Node:
	func _ready() -> void:
		print("Base _ready()")


class Derived extends Base:
	pass


class MoreDerived extends Derived:
	func _ready() -> void:
		super._ready()
		print("MoreDerived _ready()")
		
