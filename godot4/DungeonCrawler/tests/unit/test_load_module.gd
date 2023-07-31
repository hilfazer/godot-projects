extends "res://tests/gut_test_base.gd"

const CorrectModuleDataPath = "res://tests/files/modules/module_data_correct.tres"
const IncorrectDictionaryTypesPath = "res://tests/files/modules/module_data_incorrect_dict_types.tres"


func before_all():
	Debug.setLogLevel(3)


func test_load_correct_module_data():
	var module_data = ModuleData.load_and_verify_module(CorrectModuleDataPath)
	assert_not_null(module_data)
	assert_is(module_data, ModuleData)


func test_module_data_readonly():
	var module_data = ModuleData.load_and_verify_module(CorrectModuleDataPath)
	for property in module_data.get_property_list():
		if property["type"] in [TYPE_ARRAY, TYPE_DICTIONARY]:
			assert_true(module_data.get(property["name"]).is_read_only() )


func test_resource_load_failure():
	var module_data = ModuleData.load_and_verify_module("invalid path ")
	assert_null(module_data)


func test_load_incorrect_dictionary_types():
	var module_data = ModuleData.load_and_verify_module(IncorrectDictionaryTypesPath)
	assert_null(module_data)


func test_module_data_getters():
	var module_data = ModuleData.load_and_verify_module(CorrectModuleDataPath)
	var unit_path = module_data.get_unit_file_path("unitName")
	assert_eq(unit_path, "res://tests/files/modules/units.unitName.tres")
