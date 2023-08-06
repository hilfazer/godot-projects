extends Panel

const UnitLineScn            = preload("./UnitLine.tscn")
const CharacterCreationScn   = preload("res://engine/gui/CharacterCreation.tscn")
const UnitCreationDataGd     = preload("res://engine/units/UnitCreationData.gd")

var module :ModuleState

var max_units := 0:
	set(value):
		max_units = value
		_unitLimit.setMaximum( value )
		_createCharacter.disabled = _unitsCreationData.size() == max_units


var _unitsCreationData = []
var _characterCreationWindow 
@onready var _unitList = %"UnitList"
@onready var _unitLimit = $"UnitLimit"
@onready var _createCharacter = $"CreateCharacterButton"


signal unitNumberChanged(newNumber)


func _ready():
	unitNumberChanged.connect(onUnitNumberChanged)


func clearUnits():
	_unitsCreationData.clear()
	for child in _unitList.get_children():
		child.queue_free()

	unitNumberChanged.emit(_unitsCreationData.size())


func addUnit( creation_data : UnitCreationDataGd ):
	if _unitsCreationData.size() >= max_units:
		return false
	else:
		_unitsCreationData.append( creation_data )
		unitNumberChanged.emit(_unitsCreationData.size())
		return addUnitLine( _unitsCreationData.size() - 1 )


func addUnitLine( unitIdx ):
	var unitLine = UnitLineScn.instantiate()

	_unitList.add_child( unitLine )
	unitLine.initialize( unitIdx )
	unitLine.setUnit( _unitsCreationData[unitIdx] )
	unitLine.connect("deletePressed", Callable(self, "onDeleteUnit"))
	return true


func createCharacter( creation_data : UnitCreationDataGd ):
	addUnit( creation_data )


func removeUnit( unitIdx ):
	_unitsCreationData.remove_at( unitIdx )
	_unitList.get_child( unitIdx ).queue_free()
	unitNumberChanged.emit(_unitsCreationData.size())


func onDeleteUnit( unitIdx ):
	removeUnit( unitIdx )


func onCreateCharacterPressed():
	if _characterCreationWindow != null:
		return
		
	if not module:
		Debug.warn(self, "Mo module selected")
		return

	_characterCreationWindow = CharacterCreationScn.instantiate()
	add_child( _characterCreationWindow )
	_characterCreationWindow.tree_exited.connect(removeCharacterCreationWindow)
	_characterCreationWindow.madeCharacter.connect(createCharacter)
	_characterCreationWindow.initialize(module)


func removeCharacterCreationWindow():
	if not _characterCreationWindow.is_queued_for_deletion():
		_characterCreationWindow.queue_free()

	_characterCreationWindow = null


func onUnitNumberChanged( newNumber ):
	assert(newNumber <= max_units)
	_unitLimit.setCurrent( newNumber )
	_createCharacter.disabled = _unitsCreationData.size() == max_units
