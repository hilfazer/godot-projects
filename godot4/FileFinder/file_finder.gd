extends RefCounted

func _init():
	assert(false)


static func find_files_in_directory( directoryPath: String, extensionFilter := "" ) -> PackedStringArray:
	assert( directoryPath )
	assert( extensionFilter == "" or extensionFilter.get_extension() != "" )

	var dir :DirAccess = DirAccess.open(directoryPath)
	if dir == null:
		return PackedStringArray()

	var files_to_return := PackedStringArray()

	for file in dir.get_files():
		assert( dir.file_exists( file ) )
		if !extensionFilter or  "." + file.get_extension() == extensionFilter:
			files_to_return.append( dir.get_current_dir().path_join( file ) )
	
	for subdir in dir.get_directories():
		var subdirFilePaths := find_files_in_directory( \
				dir.get_current_dir().path_join( subdir ), extensionFilter )
		files_to_return.append_array( subdirFilePaths )

	return files_to_return


#this includes subclasses
static func find_scripts_of_class( scripts: PackedStringArray, klass ):
	var scriptsToReturn := PackedStringArray()

	for script in scripts:
		if script.get_extension() != "gd":
			continue

		var object = load(script).new()
		if is_instance_of(object, klass):
			scriptsToReturn.append(script)

		if not object is RefCounted:
			object.free()

	return scriptsToReturn
