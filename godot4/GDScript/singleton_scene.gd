extends Node


func _ready() -> void:
	print(a_singleton)
	
	var m = Singleton.new()
	
	var p = Singleton.instance()
	var q = Singleton.instance()
	
	print(a_singleton.a)
	pass
