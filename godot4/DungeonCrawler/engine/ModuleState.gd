extends RefCounted
class_name ModuleState

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")


var _module_data : ModuleData
var _moduleFilename : String	#TODO remove


func _init( module_data :ModuleData ) -> void:
	_module_data = module_data


func data() -> ModuleData:
	return _module_data
