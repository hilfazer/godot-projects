extends "res://tests/gut_test_base.gd"

const NodeGuardGd = preload("res://node_guard.gd")


func test_create():
	var node = Skeleton3D.new()
	var guard = NodeGuardGd.new( node )

	assert_is( guard, RefCounted )
	assert_eq( guard.node, node )


func test_setNode():
	var node = Skeleton2D.new()
	var guard = NodeGuardGd.new()
	guard.set_node( node )
	assert_eq( guard.node, node )


func test_resetNode():
	var node1 = SkeletonIK3D.new()
	var guard = NodeGuardGd.new()
	guard.set_node( node1 )
	var node2 = AnimationPlayer.new()
	guard.set_node( node2 )
	assert_freed( node1, "node1" )
	assert_not_freed( node2, "node2" )
	node2.free()


func test_release():
	var node1 = Bone2D.new()
	var guard = NodeGuardGd.new()
	guard.set_node( node1 )
	guard.release()
	assert_not_freed( node1, "node1" )
	node1.free()


func test_freeOnDestruction():
	var node1 = BoneAttachment3D.new()
	node1.add_child( Node2D.new() )
	_guardNode( node1 )
	assert_freed( node1, "node1" )


func test_dontFreeNodesInTree():
	await get_tree().process_frame

	var node1 = add_child_autoqfree(Node3D.new())
	node1.add_child( Node2D.new() )
	_guardNode( node1 )
	assert_not_freed( node1, "node1" )


static func _guardNode( node : Node ):
	var guard = NodeGuardGd.new()
	guard.set_node( node )

