extends "res://tests/gut_test_base.gd"

const CorrectModuleDataPath = "res://tests/files/modules/module_data_correct.tres"
const IncorrectDictionaryTypesPath = "res://tests/files/modules/module_data_incorrect_dict_types.tres"
const TestModulePath = "res://tests/files/modules/test_module.tres"

const COULD_NOT_LOAD = "could not load ModuleData"

func before_all():
	Debug.setLogLevel(3)


func test_load_correct_module_data():
	var module_data = ModuleLoader.load_module(CorrectModuleDataPath)
	assert_not_null(module_data)
	assert_is(module_data, ModuleData)


func test_module_data_readonly():
	var module_data = ModuleLoader.load_module(CorrectModuleDataPath)
	for property in module_data.get_property_list():
		if property["type"] in [TYPE_ARRAY, TYPE_DICTIONARY]:
			assert_true(module_data.get(property["name"]).is_read_only() )


func test_resource_load_failure():
	var module_data = ModuleLoader.load_module("invalid path ")
	assert_null(module_data)


func test_load_incorrect_dictionary_types():
	var module_data = ModuleLoader.load_module(IncorrectDictionaryTypesPath)
	assert_null(module_data)


func test_module_data_level_getters():
	var module_data = ModuleLoader.load_module(TestModulePath)
	if not(module_data is ModuleData):
		fail_test(COULD_NOT_LOAD)
		return
	
	assert_has(module_data.level_names, "test_level1")
	assert_has(module_data.level_names, "test_level2")
	assert_eq(module_data.get_level_scene_path("test_level1"), \
			"res://tests/files/modules/levels/test_level1.tscn")
	assert_eq(module_data.get_level_scene_path("test_level2"), \
			"res://tests/files/modules/levels/test_level2.tscn")
	assert_eq(module_data.get_level_zone_transition("test_level1"), "Start")
	assert_eq(module_data.get_level_zone_transition("test_level2"), "")


func test_module_data_level_connections():
	var module_data = ModuleLoader.load_module(TestModulePath)
	if not(module_data is ModuleData):
		fail_test(COULD_NOT_LOAD)
		return

	assert_eq( module_data.get_target_level_and_transition_zone("test_level1", "ToLevel2"),
			["res://tests/files/modules/levels/test_level2.tscn", "ToLevel1"] )
	assert_eq( module_data.get_target_level_and_transition_zone("test_level1", "To nowhere"),
			[] )


const TEST_UNIT_PARAMS = [
	["acid_blob", "res://tests/files/modules/units/acid_blob.tscn"],
	["artificer", "res://tests/files/modules/units/artificer.tscn"],
	["berzerker", "res://tests/files/modules/units/berzerker.tscn"],
	["skeleton_bat", "res://tests/files/modules/units/skeleton_bat.tscn"],
]


func test_module_get_unit_path( params = use_parameters(TEST_UNIT_PARAMS) ):
	var module_data = ModuleLoader.load_module(TestModulePath)
	if not(module_data is ModuleData):
		fail_test(COULD_NOT_LOAD)
		return

	assert_eq( module_data.get_unit_scene_path(params[0]), params[1] )
