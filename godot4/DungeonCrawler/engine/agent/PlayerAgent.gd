extends AgentBase

const LevelLoaderGd          = preload("res://engine/game/LevelLoader.gd")
const FogVisionBaseGd        = preload("res://engine/level/FogVisionBase.gd")
const SelectionComponentScn  = preload("res://engine/SelectionComponent.tscn")

@export_file("*FogVision.gd") var fogVisionGd : String

var _currentLevel : LevelBase: set = setCurrentLevel
var _selectedUnits := {}
var _pressedDirections :PackedByteArray = [0, 0, 0, 0]

signal travelRequested(entrance)


func _ready():
# warning-ignore:return_value_discarded
	$"SelectionBox".connect("areaSelected", Callable(self, "_selectUnitsInRect"))
	Console.connect("toggled", Callable(self, "_onConsoleVisibilityChanged"))


func _physics_process( _delta ):
	var direction := Vector2(
		_pressedDirections[3] - _pressedDirections[2], _pressedDirections[1] - _pressedDirections[0]
		)
	if !direction:
		return

	for unit in _selectedUnits:
		assert( unit is UnitBase )
		if unit.is_inside_tree():
			unit.requestedDirection = direction


func _unhandled_input(event):
	if event.is_action_pressed("gameplay_up"):
		_pressedDirections[0] = 1
	elif event.is_action_pressed("gameplay_down"):
		_pressedDirections[1] = 1
	elif event.is_action_pressed("gameplay_left"):
		_pressedDirections[2] = 1
	elif event.is_action_pressed("gameplay_right"):
		_pressedDirections[3] = 1
	elif event.is_action_released("gameplay_up"):
		_pressedDirections[0] = 0
	elif event.is_action_released("gameplay_down"):
		_pressedDirections[1] = 0
	elif event.is_action_released("gameplay_left"):
		_pressedDirections[2] = 0
	elif event.is_action_released("gameplay_right"):
		_pressedDirections[3] = 0
	elif event.is_action_pressed("travel"):
		_tryTravel()
	else:
		return

	get_viewport().set_input_as_handled()


func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_pressedDirections = [0, 0, 0, 0]


func initialize( currentLevel : LevelBase ):
	setCurrentLevel(currentLevel)


func addUnit( unit : UnitBase ):
	var addResult = super.addUnit( unit )
	_makeAPlayerUnit( unit )
	assert(addResult == OK and unit.is_in_group(Globals.Groups.PCs))
# warning-ignore:return_value_discarded
	unit.connect("clicked", Callable(self, "selectUnit").bind(unit))
	selectUnit( unit )
	_currentLevel.update()


func removeUnit( unit : UnitBase ) -> bool:
	if unit in _selectedUnits:
		deselectUnit( unit )
	var removed = super.removeUnit( unit )
	if removed:
		_unmakeAPlayerUnit( unit )

	unit.disconnect("clicked", Callable(self, "selectUnit"))
	assert(unit.is_in_group(Globals.Groups.NPCs))
	return removed


func selectUnit( unit : UnitBase ):
	assert( unit in _units.container() )

	if unit in _selectedUnits:
		return FAILED

	for child in unit.get_children():
		if child.scene_file_path != null and child.scene_file_path == SelectionComponentScn.resource_path:
			child.get_node("Perimeter").visible = true
			_selectedUnits[ unit ] = child
			return OK

	assert( !"unit %s has no selection box" % [unit] )


func deselectUnit( unit : UnitBase ):
	assert( unit in _units.container() )
	if not unit in _selectedUnits:
		return FAILED

	if is_instance_valid( _selectedUnits[ unit ] ):
		_selectedUnits[ unit ].get_node("Perimeter").visible = false

	_selectedUnits.erase( unit )
	return OK


func _selectUnitsInRect( selectionRect : Rect2 ):
	var unitsInRect := []

	for unit in _units.container():
		var unitRectShape : RectangleShape2D
		for child in unit.get_children():
			if child.scene_file_path != null and child.scene_file_path == SelectionComponentScn.resource_path:
				unitRectShape = child.get_node("CollisionShape2D").shape

		assert( unitRectShape != null )

		if     unit.global_position.x + unitRectShape.size.x > selectionRect.position.x \
			&& unit.global_position.x - unitRectShape.size.x < selectionRect.position.x + selectionRect.size.x \
			&& unit.global_position.y + unitRectShape.size.y > selectionRect.position.y \
			&& unit.global_position.y - unitRectShape.size.y < selectionRect.position.y + selectionRect.size.y:

			unitsInRect.append( unit )

	if unitsInRect.size() == 0:
		return

	for unit in _units.container():
		if unit in unitsInRect:
			selectUnit(unit)
		else:
			deselectUnit(unit)


func getSelected() -> Array:
	return _selectedUnits.keys()


func setCurrentLevel( level : LevelBase ):
	_currentLevel = level


func serialize():
	var unitNamesAndSelection := {}
	for unit in _units.container():
		assert( unit is UnitBase )
		assert( unit.is_inside_tree() )
		unitNamesAndSelection[unit.name] = unit in _selectedUnits
	return unitNamesAndSelection


func deserialize( data ):
	for unitName in data:
		assert( _currentLevel.getUnit( unitName ) )
		addUnit( _currentLevel.getUnit( unitName ) )


func postDeserialize():
	_currentLevel.update()


func _makeAPlayerUnit( unit : UnitBase ):
	var hasFogVision := false
	for child in unit.get_children():
		if child is FogVisionBaseGd:
			hasFogVision = true
			break

	if not hasFogVision:
		var fogVision : FogVisionBaseGd = load(fogVisionGd).new()
		fogVision.setExcludedRID( unit.get_rid() )
		unit.add_child( fogVision )

	var selection = SelectionComponentScn.instantiate()
	unit.add_child( selection )

	assert(unit.is_in_group(Globals.Groups.NPCs))
	unit.remove_from_group(Globals.Groups.NPCs)
	unit.add_to_group(Globals.Groups.PCs)


func _unmakeAPlayerUnit( unit : UnitBase ):
	for child in unit.get_children():
		if child is FogVisionBaseGd:
			child.queue_free()
			unit.remove_child( child )
		elif child.scene_file_path != null \
				and child.scene_file_path == SelectionComponentScn.resource_path:
			child.queue_free()
			unit.remove_child( child )

	assert(unit.is_in_group(Globals.Groups.PCs))
	unit.remove_from_group(Globals.Groups.PCs)
	unit.add_to_group(Globals.Groups.NPCs)


func _tryTravel():
	await get_tree().process_frame

	var entrance : Area2D = _currentLevel.findEntranceWithAllUnits( _unitsInTree )
	if entrance != null:
		emit_signal("travelRequested", entrance)


func _onConsoleVisibilityChanged( visible :bool ):
	setProcessing( !visible )
