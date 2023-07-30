extends Node

const DebugWindowScn         = preload("res://debug/DebugWindow.tscn")
const ConsoleLoggerGd        = preload("res://debug/ConsoleLogger.gd")
const FileLoggerGd           = preload("res://debug/FileLogger.gd")

const LogFilename = "res://logfile.log"

var _debugWindow : CanvasLayer
var _variables := {}
var _console_logger := ConsoleLoggerGd.new()
var _log_to_console := true
var _file_logger := FileLoggerGd.new(LogFilename)
var _log_to_file := true

@export var perform_prints := false

@onready var _fps_label :Label = $'CanvasLayer/VBoxContainer/FpsLabel'
@onready var _orphan_label :Label = $'CanvasLayer/VBoxContainer/OrphanLabel'

signal variables_updated()


func _init():
	set_process_mode(PROCESS_MODE_ALWAYS)


func _ready() -> void:
	if OS.has_feature("debug"):
		_repositionWindow()


func _process( _delta ):
	_fps_label.text = str(Engine.get_frames_per_second())
	var orphan_count = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_orphan_label.text = "" if not orphan_count else ("orphans: " + str(orphan_count))


func _input( event : InputEvent ):
	if event.is_action_pressed("toggle_debug_window"):
		if is_instance_valid( _debugWindow ):
			Utility.setFreeing( _debugWindow )
			_debugWindow = null
		else:
			_createDebugWindow()
	#TODO set input as handled


func info( caller : Object, message : String ):
	if _log_to_console: _console_logger.info(caller, message)
	if _log_to_file: _file_logger.info(caller, message)


func warn( caller : Object, message : String ):
	if _log_to_console: _console_logger.warn(caller, message)
	if _log_to_file: _file_logger.warn(caller, message)


func error( caller : Object, message : String ):
	if _log_to_console: _console_logger.error(caller, message)
	if _log_to_file: _file_logger.error(caller, message)


func setLogLevel( level : int ):
	_console_logger.setLogLevel(level)
	_file_logger.setLogLevel(level)


func setLogToConsole( enable : bool ):
	_log_to_console = enable


func setLogToFile( enable : bool ):
	_log_to_file = enable


func updateVariable( varName : String, value, addValue := false ):
	if value == null:
		_variables.erase(varName)
	elif addValue == true and _variables.has(varName):
		_variables[varName] += value
	else:
		_variables[varName] = value
	variables_updated.emit()


func _createDebugWindow():
	assert( _debugWindow == null )
	var debugWindow = DebugWindowScn.instantiate()

	variables_updated.connect( Callable(debugWindow, "refresh_variable_view") )
	$"/root".add_child( debugWindow )
	debugWindow.setVariables( _variables )
	_debugWindow = debugWindow


func _repositionWindow():
	var screen_size = DisplayServer.screen_get_size(0)
	var window_size = get_window().get_size()
	get_window().set_position( (screen_size*0.32 - window_size*0.4) )
