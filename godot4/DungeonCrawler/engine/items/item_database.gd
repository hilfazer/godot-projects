extends RefCounted
class_name ItemDatabase

const FilesFinderGd          = preload("res://projects/FileFinder/file_finder.gd")

const ITEM_ID                = "_itemID"

var _idsToFilepaths:         = {}

# create instances of ItemDatabase with ItemDbFactory.gd


func getItemStats(itemId : String) -> Dictionary:
	assert(_idsToFilepaths.has(itemId))
	return getAllItemsStats()[itemId]


func getAllItemsStats() -> Dictionary:
	assert(false)
	return {}


func setupItemDatabase( errorMessages: Array ) -> void:
	var idsToFilepaths := {}
	var itemStats := getAllItemsStats()
	var sceneFiles := FilesFinderGd.find_files_in_directory(
			_getDirectory(), ".tscn" )

	for itemFile in sceneFiles:
		@warning_ignore("static_called_on_instance")
		var itemId = findIdInItemFile( itemFile )
		var noErrors := true
		if itemId == ItemData.INVALID_ID:
			errorMessages.append( "No valid item id in file: %s" % itemFile )
			noErrors = false
		if idsToFilepaths.has(itemId):
			errorMessages.append( "Duplicated item id %s in file: %s" % [itemId, itemFile] )
			noErrors = false
		if not itemStats.has(itemId):
			errorMessages.append( "No item stats for id '%s' " % itemId )
			noErrors = false

		if noErrors:
			idsToFilepaths[itemId] = itemFile

	_idsToFilepaths = idsToFilepaths


func _getDirectory() -> String:
	assert(false)
	return ""


static func findIdInItemFile( itemFile: String ) -> String:
	var rootNodeId = 0
	var packedItem : Resource = load(itemFile)
	if not packedItem is PackedScene:
		Debug.error(null, "Resource is not a PackedScene")
		return ItemData.INVALID_ID

	var state = packedItem.get_state()
	for propIdx in range(0, state.get_node_property_count(rootNodeId) ):
		var pname : String = state.get_node_property_name(rootNodeId, propIdx)
		if pname == ITEM_ID:
			return state.get_node_property_value(rootNodeId, propIdx)

	return ItemData.INVALID_ID
