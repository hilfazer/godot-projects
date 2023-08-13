extends RefCounted
class_name ItemDatabase

const FilesFinderGd          = preload("res://projects/FileFinder/file_finder.gd")

const ITEM_ID                = "item_id"

var _ids_to_resources := {}


# create instances of ItemDatabase with item_factory.gd


func _init( ids2resources :Dictionary ):
	_ids_to_resources = ids2resources


func item_count() -> int:
	return _ids_to_resources.size()
	
	
func get_item_by_id( item_id :String ) -> ItemData:
	return _ids_to_resources[item_id] if _ids_to_resources.has(item_id) else null
