extends Resource
class_name ModuleData

const UnitsSubdir            = "units"
const LevelsSubdir           = "levels"

@export var unit_max                   :int = 4:
	get:
		return unit_max if unit_max > 0 else 1
@export var creation_unit_names        :Array[String] = []
@export var starting_level_name        :String = ''
@export var level_names                :Array[String] = []
@export var default_transition_zones   :Dictionary = {}
@export var level_connections          :Dictionary = {}	# "level:zone" : "level:zone"


func get_unit_scene_path( unit_name :String ) -> String:
	var file_path = _get_file_path( unit_name, UnitsSubdir )
	if file_path.is_empty():
		Debug.error( self, "Module: no file for unit with name %s" % unit_name )

	return file_path


func get_level_scene_path( level_name :String ) -> String:
	var file_path = _get_file_path( level_name, LevelsSubdir )
	if file_path.is_empty():
		Debug.error( self, "Module: no file for level with name %s" % level_name )

	return file_path




func get_unit_names_for_creation() -> Array[String]:
	return creation_unit_names


func get_level_zone_transition( level_name :String ) -> String:
	if level_name in default_transition_zones:
		return default_transition_zones[level_name]
	else:
		return ""


func get_target_level_and_transition_zone( \
		source_level_name : String, transition_zone : String ) -> Array[String]:

	assert( level_names.has(source_level_name) )
	var key :String = source_level_name + ":" + transition_zone
	if not level_connections.has( key ):
		return []

	var name_transition_pair :PackedStringArray = level_connections[ key ].split(":")
	if name_transition_pair.size() != 2:
		return []

	return [ get_level_scene_path( name_transition_pair[0] ), name_transition_pair[1] ]


func _get_file_path( name : String, subdirectory : String ) -> String:
	assert( not name.is_absolute_path() and name.get_extension().is_empty() )

	var full_path :String = resource_path.get_base_dir() + "/" + subdirectory + "/" + name + ".tscn"
	return full_path if FileAccess.file_exists( full_path ) else ""

