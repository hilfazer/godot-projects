extends Node


var Log = _Log.new()

signal toggled()


func add_command(_name, _object, _method):
	pass


func remove_command( _name ):
	pass


class _Log:
	func warn(a):
		pass

	func log(a, b=1):
		pass
