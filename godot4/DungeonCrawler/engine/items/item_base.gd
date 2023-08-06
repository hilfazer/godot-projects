extends Node
class_name ItemBase


@export var _item_id : StringName = ItemData.INVALID_ID


func _init():
	Debug.updateVariable("Item count", +1, true)


func _ready():
	assert(_item_id != ItemData.INVALID_ID)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Debug.updateVariable("Item count", -1, true)


func getID() -> String:
	return _item_id


func destroy():
	queue_free()
