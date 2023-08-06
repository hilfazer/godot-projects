extends Control

const UnitsManagerGd = preload("res://engine/gui/units_creation/units_manager.gd")

const ModuleExtensions       = ["tres"]
const NoModuleString         = "..."

var _module :ModuleState:
	set(value):
		_module = value
		_units_manager.module = value

@onready var _file_name      :LineEdit = $"ModuleSelection/FileName"
@onready var _units_manager  :UnitsManagerGd = $"UnitsManager"


signal readyForGame( module, playerUnitCreationData )
signal finished()


func _ready():
	moduleSelected( _file_name.text )
	_units_manager.unitNumberChanged.connect(onUnitNumberChanged)


func _input( event ):
	if event.is_action_pressed("ui_cancel"):
		finished.emit()
		accept_event()


func onLeaveGamePressed():
	finished.emit()


func moduleSelected( module_data_path : String ):
	clear()
	if module_data_path == NoModuleString:
		return

	if not module_data_path.get_extension() in ModuleExtensions:
		return

	if FileAccess.open( module_data_path, FileAccess.READ ) == null:
		Debug.error( self, "Module file %s can't be opened for reading" % module_data_path )
		return

	var module_data := ModuleLoader.load_module(module_data_path)
	if not module_data:
		Debug.error( self, "Incorrect module data file %s" % module_data_path )
		return
	
	_module = ModuleState.new( module_data )
	
	_file_name.text = module_data_path
	_units_manager.max_units = _module.data().unit_max


func get_module() -> ModuleState:
	return _module


func onUnitNumberChanged( number : int ):
	assert( number >= 0 )
	$"Buttons/StartGame".disabled = ( number == 0 )


func clear():
	_file_name.text = NoModuleString
	_module = null
	_units_manager.clearUnits()


func onStartGamePressed():
	readyForGame.emit(_module , _units_manager._unitsCreationData)
