extends Control

const ModuleStateGd = preload("res://engine/Module.gd")

const ModuleExtensions       = ["tres"]
const NoModuleString    = "..."

var _module : ModuleStateGd: set = setModule


signal readyForGame( module, playerUnitCreationData )
signal finished()


func _ready():
	moduleSelected( $"ModuleSelection/FileName".text )
# warning-ignore:return_value_discarded
	$"Lobby".connect("unitNumberChanged", Callable(self, "onUnitNumberChanged"))


func _notification( what ):
	if what == NOTIFICATION_PREDELETE:
		pass


func _input( event ):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("finished")
		accept_event()


func onLeaveGamePressed():
	emit_signal("finished")


func moduleSelected( moduleDataPath : String ):
	clear()
	if moduleDataPath == NoModuleString:
		return

	if not moduleDataPath.get_extension() in ModuleExtensions:
		return

	if FileAccess.open( moduleDataPath, FileAccess.READ ) == null:
		Debug.error( self, "Module file %s can't be opened for reading" % moduleDataPath )
		return

	var module = null
	var moduleResource = load( moduleDataPath )
	var moduleData: ModuleData = moduleResource.new()
#	if SavingModuleGd.verify( moduleData ):
#		module = SavingModuleGd.new( moduleData, moduleResource.resource_path )

	if not module:
		Debug.error( self, "Incorrect module data file %s" % moduleDataPath )
		return


	setModule( module )
	$"ModuleSelection/FileName".text = moduleDataPath
	$"Lobby".setMaxUnits( _module.getPlayerUnitMax() )


func onUnitNumberChanged( number : int ):
	assert( number >= 0 )
	$"Buttons/StartGame".disabled = ( number == 0 )


func clear():
	$"ModuleSelection/FileName".text = NoModuleString
	setModule( null )
	$"Lobby".clearUnits()


func onStartGamePressed():
	emit_signal("readyForGame", _module , $"Lobby"._unitsCreationData)


func setModule( module : ModuleStateGd ):
	_module = module
	$"Lobby".setModule( module )


