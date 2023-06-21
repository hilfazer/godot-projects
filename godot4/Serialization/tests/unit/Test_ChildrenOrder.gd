extends "res://tests/gut_test_base.gd"

const SerializerGd           = preload("res://hierarchical_serializer.gd")
const Scene1Scn              = preload("res://tests/files/Scene1.tscn")


func test_saveAndLoadChildrenOrder():
	randomize()
	var saveFile = _createDefaultTestFilePath("tres")

	await get_tree().process_frame

	var topChild = Scene1Scn.instantiate()
	topChild.name = "topChild"
	add_child( topChild )

	var intsArray : PackedInt32Array = range(2, 33)
	for i in intsArray:
		var node = Scene1Scn.instantiate()
		node.name = str( randi() % 10000 )
		node.ii = i
		topChild.add_child( node, true )

	var serializer := SerializerGd.new()
	assert_true( serializer.add_and_serialize( "topKey", topChild ) )
	assert_eq( OK, serializer.save_to_file( saveFile ) )

	topChild.name = "oldChild"
	assert_eq( OK, serializer.load_from_file( saveFile ) )
# warning-ignore:return_value_discarded
	serializer.get_and_deserialize( "topKey", self )

	var oldNamesArray := PackedStringArray()
	for child in topChild.get_children():
		oldNamesArray.append( child.name )

	var loadedNamesArray := PackedStringArray()
	var loadedIntsArray := PackedInt32Array()
	for child in $"topChild".get_children():
		loadedNamesArray.append( child.name )
		loadedIntsArray.append( child.ii )

	assert_eq( oldNamesArray, loadedNamesArray )
	assert_eq( intsArray, loadedIntsArray )

