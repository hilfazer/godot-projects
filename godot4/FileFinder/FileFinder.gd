extends RefCounted

func _init():
	assert(false)


static func findFilesInDirectory( directoryPath: String, extensionFilter := "" ) -> PackedStringArray:
	assert( directoryPath )
	assert( extensionFilter == "" or extensionFilter.get_extension() != "" )

	var filePaths := PackedStringArray()
	var dir = DirAccess.new()
	var error = dir.open( directoryPath )
	if error != OK:
		return PackedStringArray()

	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := findFilesInDirectory( \
					dir.get_current_dir().plus_file( file ), extensionFilter )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			if !extensionFilter or  "." + file.get_extension() == extensionFilter:
				filePaths.append( dir.get_current_dir().plus_file( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths


#this includes subclasses
static func findScriptsOfClass( scripts: PackedStringArray, klass ):
	var scriptsToReturn := PackedStringArray()

	for script in scripts:
		if script.get_extension() != "gd":
			continue

		var object = load(script).new()
		if object is klass:
			scriptsToReturn.append(script)

		if not object is RefCounted:
			object.free()

	return scriptsToReturn
