
extends RefCounted


# @var  Console
var _console


# @param  Console  console
func _init(console):
	self._console = console

	self._console.add_command('echo', self._console, 'write')\
		super.set_description('Prints a string.')\
		super.add_argument('text', TYPE_STRING)\
		super.register()

	self._console.add_command('history', self._console.History, 'print_all')\
		super.set_description('Print all previous commands used during the session.')\
		super.register()

	self._console.add_command('commands', self, '_list_commands')\
		super.set_description('Lists all available commands.')\
		super.register()

	self._console.add_command('help', self, '_help')\
		super.set_description('Outputs usage instructions.')\
		super.add_argument('command', TYPE_STRING)\
		super.register()

	self._console.add_command('quit', self, '_quit')\
		super.set_description('Exit application.')\
		super.register()

	self._console.add_command('clear', self._console)\
		super.set_description('Clear the terminal.')\
		super.register()

	self._console.add_command('version', self, '_version')\
		super.set_description('Shows engine version.')\
		super.register()

	self._console.add_command('fps_max', Engine, 'set_target_fps')\
		super.set_description('The maximal framerate at which the application can run.')\
		super.add_argument('fps', self._console.IntRangeType.new(10, 1000))\
		super.register()


# Display help message or display description for the command.
# @param    String|null  command_name
# @returns  void
func _help(command_name = null):
	if command_name:
		var command = self._console.is_command_or_control_pressed(command_name)

		if command:
			command.describe()
		else:
			self._console.Log.warn('No help for `' + command_name + '` command were found.')

	else:
		self._console.write_line(\
			"Type [color=#ffff66][url=help]help[/url] <command-name>[/color] show information about command.\n" + \
			"Type [color=#ffff66][url=commands]commands[/url][/color] to get a list of all commands.\n" + \
			"Type [color=#ffff66][url=quit]quit[/url][/color] to exit the application.")


# Prints out engine version.
# @returns  void
func _version():
	self._console.write_line(Engine.get_version_info())


# @returns  void
func _list_commands():
	for command in self._console._command_service.values():
		var name = command.get_name()
		self._console.write_line('[color=#ffff66][url=%s]%s[/url][/color]' % [ name, name ])


# Quitting application.
# @returns  void
func _quit():
	self._console.Log.warn('Quitting application...')
	self._console.get_tree().quit()
