extends Panel

const UnitCreationDataGd    = preload("res://engine/units/UnitCreationData.gd")

signal madeCharacter( creation_data )


var _module : ModuleState
@onready var _unitChoice = $"UnitChoice"


func initialize( module : ModuleState ):
	assert( module )
	_module = module

	for unit_name in module.data().creation_unit_names:
		_unitChoice.add_item( unit_name )


func makeCharacter() -> UnitCreationDataGd:
	self.queue_free()

	var unitName : String = _unitChoice.get_item_text( _unitChoice.get_selected() )
	var unit_scene_path = _module.data().get_unit_scene_path( unitName )

	if unit_scene_path.is_empty():
		return null

	var unitNode__ = load( unit_scene_path ).instantiate()
	var unitTexture = unitNode__.getIcon()
	unitNode__.free()

	var creation_data := UnitCreationDataGd.new(
		unitName,
		unitTexture
	)

	madeCharacter.emit( creation_data )
	return creation_data
