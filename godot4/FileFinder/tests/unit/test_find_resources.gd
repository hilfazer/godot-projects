extends "res://tests/gut_test_base.gd"

const FileFinderGd = preload("res://file_finder.gd")


func test_find_my_test_res_instances():
	var resource_files :PackedStringArray = FileFinderGd.find_files_in_directory( \
			"res://tests/files/resources", ".tres")
	assert_eq(resource_files.size(), 3)
	
	var my_test_res_array = FileFinderGd.find_instances_of_resource(resource_files, 'MyTestRes')
	assert_eq(my_test_res_array.size(), 2)
