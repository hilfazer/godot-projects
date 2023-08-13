extends RefCounted

const FilesFinderGd          = preload("res://projects/FileFinder/file_finder.gd")


static func load_item( item_resource_path :String ) -> ItemData:
	return ResourceLoader.load(item_resource_path, "ItemBase")


static func create_item_database( root_directory :String ) -> ItemDatabase:
	assert(root_directory.is_absolute_path() || root_directory.is_relative_path())

	var ids2resources :Dictionary = {}
	var res_files := FilesFinderGd.find_files_in_directory(root_directory, ".tres")
	var item_files := FilesFinderGd.find_resources_of_class(res_files, ItemData)

	for item_path in item_files:
		var any_errors := false
		if not resource_has_matching_scene(item_path):
			Debug.warn(null, "Item Factory: resource %s has no matching scene" % item_path)
			any_errors = true

		var item = load_item(item_path)
		if item == null:
			Debug.warn(null, "Item Factory: item resource %s could not be loaded" % item_path)
		else:
			if item.item_id == ItemData.INVALID_ID:
				Debug.warn(null, "Item Factory: item %s has invalid id" % item_path)
				any_errors = true

			if ids2resources.has(item.item_id):
				Debug.warn(null, "Item Factory: duplicated item id: %s" % item.item_id)
				any_errors = true

			if not any_errors:
				ids2resources[item.item_id] = item

	var item_database = ItemDatabase.new(ids2resources)
	return item_database


static func resource_has_matching_scene( item_res_path :String ) -> bool:
	var scene_path = item_res_path.get_basename() + ".tscn"
	return FileAccess.file_exists(scene_path)
