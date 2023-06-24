extends "res://addons/gut/test.gd"

const EPSILON = 0.00001
const FILES_DIR = "user://"

# warning-ignore:unused_class_variable
var _resourceExtension := ".tres" if OS.has_feature("debug") else ".res"
var _filesAtStart := PackedStringArray()


func _init():
	assert( DirAccess.new().dir_exists( FILES_DIR ) )

	var script = get_script().resource_path.get_file()
	if script:
		name = script


func before_each():
	assert( _filesAtStart.is_empty() )

	_filesAtStart = _findFilesInDirectory( FILES_DIR )
	print("before_each()")


func after_each():
	for child in get_children():
		child.free()
	assert( get_child_count() == 0 )

	var filesNow : PackedStringArray = _findFilesInDirectory( FILES_DIR )
	for filePath in filesNow:
		if not filePath in _filesAtStart:
			gut.file_delete( filePath )
	_filesAtStart.resize( 0 )


func _createDefaultTestFilePath( extension : String ) -> String:
	return FILES_DIR.plus_file( gut.get_current_test_object().name ) \
		+ ("." + extension if extension else "")


static func _findFilesInDirectory( directoryPath : String ) -> PackedStringArray:
	assert( directoryPath )

	var filePaths := PackedStringArray()

	var dir = DirAccess.new()
	dir.open( directoryPath )
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := _findFilesInDirectory( \
					dir.get_current_dir().plus_file( file) )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			filePaths.append( dir.get_current_dir().plus_file( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths
