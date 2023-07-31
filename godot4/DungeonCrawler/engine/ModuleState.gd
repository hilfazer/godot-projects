extends RefCounted
class_name ModuleState

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")


var _module_data : ModuleData
var _moduleFilename : String


func _init( module_data :ModuleData ) -> void:
	_module_data = module_data


func data() -> ModuleData:
	return _module_data


func getLevelEntrance( levelName : String ) -> String:
	if levelName in _module_data.DefaultLevelEntrances:
		return _module_data.DefaultLevelEntrances[levelName]
	else:
		return ""


#func getLevelFilename( levelName : String ) -> String:
#	assert( not levelName.is_absolute_path() and levelName.get_extension().is_empty() )
#	if not _module_data.LevelNames.has(levelName):
#		Debug.info( self, "Module: no level named %s" % levelName )
#		return ""
#
#	var fileName = _getFilename( levelName, LevelsSubdir )
#	if fileName.is_empty():
#		Debug.error( self, "Module: no file for level with name %s" % levelName )
#
#	return fileName


#func get_target_level_and_transition_zone( \
#		sourceLevelName : String, transition_zone : String ) -> PackedStringArray:
#	assert( _module_data.LevelNames.has(sourceLevelName) )
#	if not _module_data.LevelConnections.has( [sourceLevelName, transition_zone] ):
#		return PackedStringArray()
#
#	var name_entrance : PackedStringArray = \
#			_module_data.LevelConnections[[sourceLevelName, transition_zone]]
#
#	return PackedStringArray([ getLevelFilename( name_entrance[0] ), name_entrance[1] ])
