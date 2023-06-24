# this class will prevent memory leak by freeing Node if it's outside of SceneTree
# and doesn't have a parent
# call release() if you want to handle memory yourself
extends RefCounted

var _node : Node
var node : Node:
	set(n):
		set_node(n)
	get:
		return _node


func _init( node_ : Node = null ):
	_node = node_


func release() -> Node:
	var to_return = _node
	_node = null
	return to_return


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid( _node ) \
			and not _node.is_inside_tree() \
			and not _node.get_parent():
			_node.free()


func set_node( new_node : Node ):
	if new_node != _node:
		if is_instance_valid( _node ) \
			and not _node.is_inside_tree() \
			and not _node.get_parent():
			_node.free()
		_node = new_node
