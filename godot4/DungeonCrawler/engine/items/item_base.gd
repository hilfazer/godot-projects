extends Node
class_name ItemBase


func _init():
	Debug.updateVariable("Item count", +1, true)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Debug.updateVariable("Item count", -1, true)


func destroy():
	queue_free()
