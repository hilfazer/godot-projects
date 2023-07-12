extends "res://tests/GutTestBase.gd"

const FileFinderGd = preload("res://FileFinder.gd")
const NodeSubclassGd = preload("res://tests/files/NodeSubclass.gd")


func test_findNodeSubclasses():
	var scripts := PoolStringArray()
	scripts.append("res://tests/files/NodeSubclass.gd")
	var nodeSubclasses = FileFinderGd.findScriptsOfClass(scripts, Node)
	assert_eq(nodeSubclasses.size(), 1)

	var node2Dsubclasses = FileFinderGd.findScriptsOfClass(scripts, Node2D)
	assert_eq(node2Dsubclasses.size(), 0)

	var node_subclass_subclasses = FileFinderGd.findScriptsOfClass(scripts, NodeSubclassGd)
	assert_eq(node_subclass_subclasses.size(), 1)
