extends Node
class_name LevelBase


@onready var _ground :GenericTilemap = $"Ground"
@onready var _units  :LevelUnits = $"Units"
@onready var _items  :LevelItems = $"Items"
@onready var _fog    :FogOfWar = $"FogOfWar"
@onready var _transition_zones_parent :Node = $"TransitionZones"


signal predelete()


func _init():
	Debug.updateVariable( "Level count", +1, true )


func _ready():
	applyFogToLevel( _fog.fill_tile )
	update()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable( "Level count", -1, true )


func setGroundTile( tileName, x, y ):
	_ground.setTile( tileName, x, y )


func removeChildUnit( unitNode ):
	assert( _units.has_node( unitNode.get_path() ) )
	_units.remove_child( unitNode )


func find_transition_zone_with_all_units( unitNodes ) -> Area2D:
	var entranceWithUnits = find_transition_zone_with_any_units( unitNodes )

	if !entranceWithUnits:
		return null

	if Utility.isSuperset( entranceWithUnits.get_overlapping_bodies(), unitNodes ):
		return entranceWithUnits
	else:
		return null


func find_transition_zone_with_any_units( unitNodes ) -> Area2D:
	var transition_zones : Array[Node] = _transition_zones_parent.get_children()

	var entranceWithAnyUnits : Area2D = null
	for zone in transition_zones:
		if entranceWithAnyUnits != null:
			break

		for body in zone.get_overlapping_bodies():
			if unitNodes.has( body ):
				entranceWithAnyUnits = zone
				break

	return entranceWithAnyUnits


func applyFogToLevel( fogTileType : int ):
	_fog.fill_tilemap_area_with_tile( _ground, fogTileType )


func addUnitToFogVision( unit : UnitBase ) -> Error:
	if not _units.has_node( NodePath(unit.name) ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unit.name] )
		return FAILED

	var fogVision = FogOfWar.fogVisionFromNode( unit )
	if not FogOfWar.fogVisionFromNode( unit ):
		Debug.warn( self, "Unit %s has no fog vision" % [unit.name] )
		return FAILED

	return _fog.addFogVision( fogVision )


func removeUnitFromFogVision( unit : UnitBase ) -> Error:
	if not _units.has_node( NodePath(unit.name) ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unit.name] )
		return FAILED

	var fogVision = FogOfWar.fogVisionFromNode( unit )
	if not fogVision:
		Debug.warn( self, "Unit %s has no fog vision" % [unit.name] )
		return FAILED

	return _fog.removeFogVision( fogVision )


func getFogVisions() -> Array:
	return _fog.getFogVisions()


func addUnit( unit : UnitBase ) -> Error:
	if unit in _units.get_children():
		return FAILED

	_units.add_child( unit, true )
	assert( unit in _units.get_children() )

	var fogVision = FogOfWar.fogVisionFromNode( unit )
	if not fogVision:
		return OK

	assert( not fogVision in _fog.getFogVisions() )
	return addUnitToFogVision( unit )


func removeUnit( unit : UnitBase ):
	if not unit in _units.get_children():
		return NodeGuard.new()

	var guard := NodeGuard.new( unit )
	_units.remove_child( unit )

	assert( not unit in _fog.getFogVisions() )
	assert( not unit in _units.get_children() )
	return guard


func update():
	for unit in _units.get_children():
		var fogVision = FogOfWar.fogVisionFromNode( unit )
		if fogVision != null and not fogVision in _fog.getFogVisions():
			addUnitToFogVision( unit )


func getUnit( unitName : String ) -> UnitBase:
	assert( unitName )
	return _units.get_node_or_null( unitName )


func getAllUnits() -> Array:
	return _units.get_children()


func getItem( itemName : String ) -> ItemBase:
	assert( itemName )
	return _items.get_node_or_null( itemName )


func file_name() -> String:
	return scene_file_path.get_basename().get_file()
