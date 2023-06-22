extends "res://tests/gut_test_base.gd"

const SerializerGd           = preload("res://hierarchical_serializer.gd")
const NodeGuardGd            = preload("res://node_guard.gd")
const FiveNodeBranchScn      = preload("res://tests/files/FiveNodeBranch.tscn")
const PostDeserializeScn     = preload("res://tests/files/PostDeserialize.tscn")


func test_saveToFile():
	var serializer = SerializerGd.new()

	var saveFileNoDir = "noDirectory"
	var err = serializer.save_to_file( saveFileNoDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileNoDir + _resourceExtension )
# warning-ignore:return_value_discarded
	DirAccess.open(".").remove( saveFileNoDir + _resourceExtension )

	var saveFileUserDir = "user://ww/userDir.tres"
	err = serializer.save_to_file( saveFileUserDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileUserDir )
# warning-ignore:return_value_discarded
	DirAccess.open(".").remove( saveFileUserDir )

	var saveFileWrongPath = "bah://wrong/Path.tres"
	err = serializer.save_to_file( saveFileWrongPath )
	assert_eq( err, ERR_CANT_CREATE )
	assert_file_does_not_exist( saveFileWrongPath )


func test_saveVersion():
	var version := "0.4.3"
	var serializer = SerializerGd.new()
	var saveFile = "user://versionSave.tres"

	ProjectSettings.set_setting( "application/config/version", version )

	var err = serializer.save_to_file( saveFile )
	assert_file_exists( saveFile )
	assert_eq( err, OK )
	assert_eq( serializer.get_version(), version )

	err = serializer.load_from_file( saveFile )
	assert_eq( err, OK )
	assert_eq( serializer.get_version(), version )


func test_saveUserData():
	var serializer = SerializerGd.new()
	var saveFile = "user://userDataSave.tres"
	var dict = { "d":5, 1:2, 3:4.5678 }
	var arr = [0, Vector2(1.1, 2.2), 8, null]

	serializer.user_data["DICT"] = dict
	serializer.user_data["ARR"] = arr
	var err = serializer.save_to_file( saveFile )
	assert_file_exists( saveFile )
	assert_eq( err, OK )

	serializer = SerializerGd.new()

	err = serializer.load_from_file( saveFile )
	assert_eq( err, OK )

	assert_almost_eq( serializer.user_data["DICT"][3], dict[3], EPSILON )
	assert_eq( serializer.user_data["DICT"]["d"], dict["d"] )
	assert_eq( serializer.user_data["ARR"][1], arr[1] )
	assert_eq( serializer.user_data["ARR"][3], arr[3] )
