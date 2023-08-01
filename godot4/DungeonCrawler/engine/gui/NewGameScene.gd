extends Control

const ModuleExtensions       = ["tres"]
const NoModuleString    = "..."

var _module : ModuleState:
	set(value):
		_module = value
		$"Lobby".setModule( value )


signal readyForGame( module, playerUnitCreationData )
signal finished()


func _ready():
	moduleSelected( $"ModuleSelection/FileName".text )
# warning-ignore:return_value_discarded
	$"Lobby".connect("unitNumberChanged", Callable(self, "onUnitNumberChanged"))

func _input( event ):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("finished")
		accept_event()


func onLeaveGamePressed():
	emit_signal("finished")


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
	
	$"ModuleSelection/FileName".text = module_data_path
	$"Lobby".setMaxUnits( _module.getPlayerUnitMax() )


func get_module() -> ModuleState:
	return _module


func onUnitNumberChanged( number : int ):
	assert( number >= 0 )
	$"Buttons/StartGame".disabled = ( number == 0 )


func clear():
	$"ModuleSelection/FileName".text = NoModuleString
	_module = null
	$"Lobby".clearUnits()


func onStartGamePressed():
	emit_signal("readyForGame", _module , $"Lobby"._unitsCreationData)
