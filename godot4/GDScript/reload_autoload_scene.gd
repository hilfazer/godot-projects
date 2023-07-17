extends Control

const ReloadAutoloadGd = preload("res://reload_autoload.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ReloadAutoload.a = 2
#	ReloadAutoload = ReloadAutoloadGd.new()
	var _auto = $"/root/ReloadAutoload"
	_auto = ReloadAutoloadGd.new()

	print(ReloadAutoload.a)
