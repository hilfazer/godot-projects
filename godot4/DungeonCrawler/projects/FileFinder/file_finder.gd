extends RefCounted

func _init():
	assert(false)


static func find_files_in_directory( directoryPath: String, extensionFilter := "" ) -> PackedStringArray:
	assert( directoryPath )
	assert( extensionFilter == "" or extensionFilter.get_extension() != "" )

	var dir: DirAccess = DirAccess.open(directoryPath)
	if dir == null:
		return PackedStringArray()

	var filePaths := PackedStringArray()
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := find_files_in_directory( \
					dir.get_current_dir().path_join( file ), extensionFilter )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			if !extensionFilter or  "." + file.get_extension() == extensionFilter:
				filePaths.append( dir.get_current_dir().path_join( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths


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
