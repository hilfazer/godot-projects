extends "res://tests/gut_test_base.gd"

const FileFinderGd = preload("res://file_finder.gd")
const NodeSubclassGd = preload("res://tests/files/NodeSubclass.gd")

const NodeSubclassPath = "res://tests/files/NodeSubclass.gd"

func test_find_scripts_including_subclasses():
	var scripts := PackedStringArray()
	scripts.append(NodeSubclassPath)
	var nodeSubclasses = FileFinderGd.find_scripts_of_class(scripts, Node)
	assert_eq(nodeSubclasses.size(), 1)
	assert_has(nodeSubclasses, NodeSubclassPath)

	var node2Dsubclasses = FileFinderGd.find_scripts_of_class(scripts, Node2D)
	assert_eq(node2Dsubclasses.size(), 0)

	var node_subclass_subclasses = FileFinderGd.find_scripts_of_class(scripts, NodeSubclassGd)
	assert_eq(node_subclass_subclasses.size(), 1)
	assert_has(node_subclass_subclasses, NodeSubclassPath)
