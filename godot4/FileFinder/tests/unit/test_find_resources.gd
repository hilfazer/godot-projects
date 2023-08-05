extends "res://tests/gut_test_base.gd"

const FileFinderGd = preload("res://file_finder.gd")


const RESOURCE_PATHS = [
	"res://tests/files/resources/test_res1.tres",
	"res://tests/files/resources/dir1/test_res2.tres",
	"res://tests/files/resources/test_res3.tres",
	"res://tests/files/resources/test_res_sub1.tres",
]


func test_find_my_test_res_instances():
	var resource_files :PackedStringArray = FileFinderGd.find_files_in_directory( \
			"res://tests/files/resources", ".tres")
	assert_eq(resource_files.size(), RESOURCE_PATHS.size())
	
	var my_test_res_array = FileFinderGd.find_instances_of_resource(resource_files, 'MyTestRes')
	assert_eq(my_test_res_array.size(), 2)
	assert_has(my_test_res_array, RESOURCE_PATHS[0])
	assert_has(my_test_res_array, RESOURCE_PATHS[1])
