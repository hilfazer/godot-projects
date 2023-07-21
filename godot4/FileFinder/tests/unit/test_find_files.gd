extends "res://tests/gut_test_base.gd"

const FileFinderGd = preload("res://file_finder.gd")

func test_find_files_in_directory():

	var files = FileFinderGd.find_files_in_directory("res://tests/files/test1")
	assert_eq(files.size(), 4)


var params1 = ParameterFactory.named_parameters(['ext', 'count'], \
	[[".txt", 3], [".ini", 1], ['.nnn', 0]] \
	)

func test_findFilesWithExtensionInDirectory(params=use_parameters(params1)):
	var files = FileFinderGd.find_files_in_directory("res://tests/files/test1", params.ext)
	assert_eq(files.size(), params.count)

	var extensionMatches := 0
	for file in files:
		extensionMatches += int("." + file.get_extension() == params.ext)

	assert_eq(extensionMatches, params.count, "incorrect number of %s files" % params.ext)


func test_nonexistentDirectory():
	var files = FileFinderGd.find_files_in_directory("res://doesnt_exist", ".txt")
	assert_eq(files.size(), 0)

	files = FileFinderGd.find_files_in_directory("res://doesnt_exist", ".ini")
	assert_eq(files.size(), 0)
