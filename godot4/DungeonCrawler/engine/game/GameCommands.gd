extends "res://debug/CommandHolder.gd"

const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")

@onready var _game           :GameScene = get_parent()
@onready var _playerAgent    :PlayerAgentGd = _game.get_node('PlayerAgent')


func _unhandled_input(event):
	if event.is_action("select_unit_1"):
		selectPlayerUnitByNumber( 1 )
		get_viewport().set_input_as_handled()
	elif event.is_action("select_unit_2"):
		selectPlayerUnitByNumber( 2 )
		get_viewport().set_input_as_handled()
	elif event.is_action("select_unit_3"):
		selectPlayerUnitByNumber( 3 )
		get_viewport().set_input_as_handled()
	elif event.is_action("select_unit_4"):
		selectPlayerUnitByNumber( 4 )
		get_viewport().set_input_as_handled()
	elif event.is_action("select_unit_all"):
		selectAllPlayerUnits()
		get_viewport().set_input_as_handled()


func _registerCommands():
	registerCommand(
		"unloadLevel",
		"unloads current level",
		[]
		)

	registerCommand(
		"loadLevel",
		"loads a level",
		[ ['levelName', TYPE_STRING] ]
		)

	registerCommand(
		"addUnitToPlayer",
		"unloads current level",
		[ ['unitName', TYPE_STRING] ]
		)

	registerCommand(
		"removeUnitFromPlayer",
		"unloads current level",
		[ ['unitName', TYPE_STRING] ]
		)

	registerCommand(
		"selectPlayerUnit",
		"selects player's unit",
		[ ['name', TYPE_STRING] ]
		)

	registerCommand(
		"deselectPlayerUnit",
		"deselects player's unit",
		[ ['name', TYPE_STRING] ]
		)


func unloadLevel():
	get_parent().unloadCurrentLevel()


func loadLevel( levelName : String ):
	if levelName.is_empty():
		Console.Log.warn( "Level name can't be empty" )
		return

	var game = get_parent()
	if game._module == null:
		await get_tree().process_frame
		return

	var result = await game.loadLevel( levelName )
	if result != OK:
		Console.Log.warn( "Failed to load level [b]%s[/b]." % levelName )


func addUnitToPlayer( unitName : String ):
	if unitName.is_empty():
		Console.Log.warn( "Unit name can't be empty" )
		return

	var game : GameScene = get_parent()

	if not is_instance_valid( game.currentLevel ):
		Console.Log.warn( "No current level" )
		return

	var unitNode = game.currentLevel.getUnit( unitName )
	if unitNode == null:
		return

	if not unitNode in _playerAgent.getUnits():
		_playerAgent.addUnit( unitNode )


func removeUnitFromPlayer( unitName : String ):
	if unitName.is_empty():
		Console.Log.warn( "Unit name can't be empty" )
		return

	var game = get_parent()

	if not is_instance_valid( game.currentLevel ):
		Console.Log.warn( "No current level" )
		return

	var unitNode = game.currentLevel.getUnit( unitName )
	if unitNode == null:
		return

	_playerAgent.removeUnit(unitNode)


func selectPlayerUnit( unitName : String ):
	var playerUnit : UnitBase
	for unit in _playerAgent.getUnits():
		if unit.name == unitName:
			playerUnit = unit
			break

	if playerUnit == null:
		Console.Log.warn("No player unit named %s " % [unitName] )
		return

	_playerAgent.selectUnit( playerUnit )


func selectPlayerUnitByNumber( unitOrder : int ):
	var units : Array[UnitBase] = _playerAgent.getUnits()

	for i in range(0, units.size()):
		if i == unitOrder - 1:
			_playerAgent.selectUnit( units[i] )
		else:
			_playerAgent.deselectUnit( units[i] )


func selectAllPlayerUnits():
	var units : Array[UnitBase] = _playerAgent.getUnits()

	for i in range(0, units.size()):
			_playerAgent.selectUnit( units[i] )


func deselectPlayerUnit( unitName : String ):
	var playerUnit : UnitBase
	for unit in _playerAgent.getUnits():
		if unit.name == unitName:
			playerUnit = unit
			break

	if playerUnit == null:
		Console.Log.warn("No player unit named %s " % [unitName] )
		return

	_playerAgent.deselectUnit( playerUnit )

