extends Node

const ConstPreloadGd = preload("res://singleton.gd")

var a : ConstPr = ConstPreloadGd.new()
@onready var b = ConstPreloadGd
