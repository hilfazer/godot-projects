extends RefCounted

func _init():
	assert(false)


static func find_files_in_directory( directoryPath :String, extensionFilter := "" ) -> PackedStringArray:
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
static func find_scripts_of_class( scripts :PackedStringArray, klass ) -> PackedStringArray:
	var to_return := PackedStringArray()

	for script in scripts:
		if script.get_extension() != "gd":
			continue

		var object = load(script).new()
		if is_instance_of(object, klass):
			to_return.append(script)

		if not object is RefCounted:
			object.free()

	return to_return
	
	
#this includes subclasses
static func find_resources_of_class( files :PackedStringArray, klass ) -> PackedStringArray:
	var to_return := PackedStringArray()
	
	for file in files:
		if file.get_extension() != "tres":
			continue
			
		var resource = load(file)
		if is_instance_of(resource, klass):
			to_return.append(file)

	return to_return


static func find_resources_of_class_name(
		files :PackedStringArray, klass_name :String ) -> PackedStringArray:

	var to_return := PackedStringArray()
	const SCRIPT_CLASS_KEY := ' script_class="'

	for file_path in files:
		if file_path.get_extension() != "tres":
			continue
		
		var file = FileAccess.open(file_path, FileAccess.READ)
		var split_first_line = file.get_line().split(SCRIPT_CLASS_KEY)
		if split_first_line.size() <= 1:
			continue
			
		if split_first_line[1].begins_with(klass_name+'"'):
			to_return.append(file_path)
			
	return to_return
