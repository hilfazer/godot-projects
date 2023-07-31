extends Panel

const UnitCreationDataGd    = preload("res://engine/units/UnitCreationData.gd")

signal madeCharacter( creation_data )


var _module : ModuleState
@onready var _unitChoice = $"UnitChoice"


func initialize( module : ModuleState ):
	assert( module )
	_module = module

	for unitPath in module.getUnitsForCreation():
		_unitChoice.add_item( unitPath )


func makeCharacter() -> UnitCreationDataGd:
	self.queue_free()

	var unitName : String = _unitChoice.get_item_text( _unitChoice.get_selected() )
	var unitFilename = _module.getUnitFilename( unitName )

	if unitFilename.is_empty():
		return null

	var unitNode__ = load( unitFilename ).instantiate()
	var unitTexture = unitNode__.getIcon()
	unitNode__.free()

	var creation_data := UnitCreationDataGd.new(
		unitName,
		unitTexture
	)

	emit_signal( "madeCharacter", creation_data )
	return creation_data
