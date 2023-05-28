extends Node

enum Handling {no, input, gui, unhandled}

@export var _detectMouseClick: bool = true
@export var _handleMouseClick: Handling = Handling.no

@export var _detectKeys: bool = true
@export var _handleKeys: Handling = Handling.no

@export var _detectInput: bool = true: set = _setDetectInput
@export var _detectUnhandledInput: bool = true: set = _setDetectUnhandledInput


func _ready():
	set_process_input( _detectInput )
	set_process_unhandled_input( _detectUnhandledInput )
	set_process_unhandled_key_input( _detectUnhandledInput )


func _input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.input
		if doHandle:
			get_viewport().set_input_as_handled()
		printEvent( event, '_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.input
		if doHandle:
			get_viewport().set_input_as_handled()
		printEvent( event, '_input', doHandle )


func _unhandled_input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.unhandled
		if doHandle:
			get_viewport().set_input_as_handled()
		printEvent( event, '_unhandled_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.unhandled
		if doHandle:
			get_viewport().set_input_as_handled()
		printEvent( event, '_unhandled_input', doHandle )


func _gui_input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.gui
		doHandle && call("accept_event")
		printEvent( event, '_gui_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.gui
		doHandle && call("accept_event")
		printEvent( event, '_gui_input', doHandle )


func printEvent( event : InputEvent, function : String, handled : bool ):
	if event.is_pressed() == false:
		return

	print( "%-40s %-25s %s \n\t\t %s"
		% [get_path(), function, "[HANDLED]" if handled else "", event.as_text()] )


func _setDetectInput( set ):
	_detectInput = set
	set_process_input( set )


func _setDetectUnhandledInput( set ):
	_detectUnhandledInput = set
	set_process_unhandled_input( set )
	set_process_unhandled_key_input( set )
