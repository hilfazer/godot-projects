extends GutTest

const EPSILON = 0.00001
const FILES_DIR = "user://gut_tests"

@warning_ignore("unused_private_class_variable")
var _resourceExtension := ".tres" if OS.has_feature("debug") else ".res"
var _filesAtStart := PackedStringArray()


func _init():
	if not DirAccess.dir_exists_absolute( FILES_DIR ):
		DirAccess.make_dir_absolute( FILES_DIR )

	assert( DirAccess.dir_exists_absolute( FILES_DIR ) )

	var script = get_script().resource_path.get_file()
	if script:
		name = script


func before_each():
	assert( _filesAtStart.size() == 0 )

	_filesAtStart = _find_files_in_directory( FILES_DIR )


func after_each():
	var filesNow : PackedStringArray = _find_files_in_directory( FILES_DIR )
	for filePath in filesNow:
		if not filePath in _filesAtStart:
			gut.file_delete( filePath )
	_filesAtStart.resize( 0 )


func _createDefaultTestFilePath( extension : String ) -> String:
	return FILES_DIR.path_join( gut.get_current_test_object().name ) \
		+ ("." + extension if extension else "")


static func _find_files_in_directory( directoryPath : String ) -> PackedStringArray:
	assert( directoryPath )

	var filePaths := PackedStringArray()

	var dir = DirAccess.open( directoryPath )
	dir.list_dir_begin()

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := _find_files_in_directory( \
					dir.get_current_dir().path_join( file) )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			filePaths.append( dir.get_current_dir().path_join( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths
