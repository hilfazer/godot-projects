extends Node

var _commands : PackedStringArray


func _ready():
	_registerCommands()


func _notification( what ):
	match what:
		NOTIFICATION_PREDELETE:
			_unregisterCommands()


func registerCommand( commandName :String, description :String, argArray := [], method = null ):
	if method:
		assert(has_method(method))
	else:
		assert(has_method(commandName))

	var command = Console.add_command(commandName, self, method)
	command.set_description(description)

	for arg in argArray:
		assert(arg is Array and arg.size() >= 2)
		command.add_argument(arg[0], arg[1])

	command.register()

	@warning_ignore("return_value_discarded")
	_commands.append(commandName)


func _registerCommands():
	pass


func _unregisterCommands():
	for commandName in _commands:
		Console.remove_command( commandName )
	_commands = []
