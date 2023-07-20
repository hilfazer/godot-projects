extends Node
class_name Singleton

static var _instance : Singleton = null


func _init() -> void:
	assert(not _instance)
	print(_instance)
	_instance = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_instance = null


static func instance():
	if not _instance:
		_instance = Singleton.new()

	return _instance
