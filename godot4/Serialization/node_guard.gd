# this class will prevent memory leak by freeing Node if it's outside of SceneTree
# and doesn't have a parent
# call release() if you want to handle memory yourself
extends RefCounted


var node : Node: set = set_node


func _init( node_ : Node = null ):
	node = node_


func release() -> Node:
	var to_return = node
	node = null
	return to_return


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid( node ) \
			and not node.is_inside_tree() \
			and not node.get_parent():
			node.free()


func set_node( new_node : Node ):
	if new_node != node:
		if is_instance_valid( node ) \
			and not node.is_inside_tree() \
			and not node.get_parent():
			node.free()
		node = new_node
