extends Resource
class_name ModuleData

const COULD_NOT_LOAD_MODULE := "Could not load %s as ModuleData"
const INCORRECT_VALUE_TYPE := "%s has value(s) of type different than %s"

@export var unit_max                   :int = 4
@export var unit_names                 :Array[String] = []
@export var starting_level_name        :String = ''
@export var level_names                :Array[String] = []
@export var default_transition_zones   :Dictionary = {}
@export var level_connections          :Dictionary = {}



static func load_and_verify_module( module_path :String ) -> ModuleData:
	var resource = ResourceLoader.load(module_path, "ModuleData")
	if not resource is ModuleData:
		Debug.info(null, COULD_NOT_LOAD_MODULE % module_path)
		return null

	var module :ModuleData = resource
	for property in module.get_property_list():
		if property["type"] in [TYPE_ARRAY, TYPE_DICTIONARY]:
			module.get(property["name"]).make_read_only()

	var incorrect_keys = \
			module.default_transition_zones.keys().filter(func(a): return typeof(a) != TYPE_STRING)
	var incorrect_values = \
			module.default_transition_zones.values().filter(func(a): return typeof(a) != TYPE_STRING)
	if incorrect_keys.size() + incorrect_values.size() > 0:
		Debug.info(null, INCORRECT_VALUE_TYPE % ['default_transition_zones', 'TYPE_STRING'])
		return null

	return module
