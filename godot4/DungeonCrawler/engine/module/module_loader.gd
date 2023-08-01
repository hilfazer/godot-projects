class_name  ModuleLoader

const COULD_NOT_LOAD_MODULE := "Could not load file '%s' as ModuleData"
const INCORRECT_VALUE_TYPE := "%s has value(s) of type different than %s"
const MAX_UNITS_TOO_LOW := "Maximum number of units lower than 1"
const STARTING_LEVEL_NAME_EMPTY := "Starting level name is empty"


func _init():
	assert(false)
	
	
static func load_module( module_path :String ) -> ModuleData:
	var module = ResourceLoader.load(module_path, "ModuleData")
	if not module is ModuleData:
		Debug.info(null, COULD_NOT_LOAD_MODULE % module_path)
		return null

	for property in module.get_property_list():
		if property["type"] in [TYPE_ARRAY, TYPE_DICTIONARY]:
			module.get(property["name"]).make_read_only()

	return module if _verify_module(module) else null


static func _verify_module( module :ModuleData ) -> bool:
	var any_errors := false

	if module.unit_max < 1:
		Debug.info(null, MAX_UNITS_TOO_LOW)

	if module.starting_level_name == '':
		Debug.info(null, STARTING_LEVEL_NAME_EMPTY)
		any_errors = true

	var incorrect_keys = \
			module.default_transition_zones.keys().filter(func(a): return typeof(a) != TYPE_STRING)
	var incorrect_values = \
			module.default_transition_zones.values().filter(func(a): return typeof(a) != TYPE_STRING)
	if incorrect_keys.size() + incorrect_values.size() > 0:
		Debug.info(null, INCORRECT_VALUE_TYPE % ['default_transition_zones', 'TYPE_STRING'])
		any_errors = true

	incorrect_keys = \
			module.level_connections.keys().filter(func(a): return typeof(a) != TYPE_STRING)
	incorrect_values = \
			module.level_connections.values().filter(func(a): return typeof(a) != TYPE_STRING)
	if incorrect_keys.size() + incorrect_values.size() > 0:
		Debug.info(null, INCORRECT_VALUE_TYPE % ['level_connections', 'TYPE_STRING'])
		any_errors = true

	return not any_errors
