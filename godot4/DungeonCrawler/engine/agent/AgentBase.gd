extends Node
class_name AgentBase


var _controlled_units := SetWrapper.new()
var _unitsInTree := []


signal units_changed( units )


func _init():
	_controlled_units.changed.connect( Callable(self, "_update_active_units") )
	add_to_group( Constants.Groups.Agents )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for unit in _controlled_units.container():
			if is_instance_valid( unit ):
				unit.set_meta( Constants.Meta.Agent, null )


func addUnit( unit : UnitBase ) -> Error:
	assert( unit != null )
	assert( not unit in _controlled_units.container() )

	if unit.has_meta( Constants.Meta.Agent ):
		var agent : AgentBase = unit.get_meta( Constants.Meta.Agent ).get_ref()

		if agent != null:
			var removed = agent.removeUnit( unit )
			assert( removed == true )
			Debug.info( self, "Removed agent %s from unit %s" % [agent.name, unit.name] )

	_controlled_units.add( [unit] )
	unit.tree_entered.connect(Callable(self, "_setActive").bind(unit))
	unit.tree_exited.connect(Callable(self, "_setInactive").bind(unit))
	unit.predelete.connect(Callable(self, "remove_deleted_unit").bind(unit), CONNECT_ONE_SHOT)
	if unit.is_inside_tree():
		_setActive( unit )

	unit.set_meta( Constants.Meta.Agent, weakref(self) )
	return OK


func removeUnit( unit : UnitBase ) -> bool:
	if not _controlled_units.container().has( unit ):
		Debug.info( self, "Agent %s has no unit named %s" % [self.name, unit.name] )
		return false

	_controlled_units.remove( [unit] )
	unit.tree_entered.disconnect(Callable(self, "_setActive"))
	unit.tree_exited.disconnect(Callable(self, "_setInactive"))
	unit.set_meta( Constants.Meta.Agent, null )
	return true


func remove_deleted_unit( unit :UnitBase ):
	if not _controlled_units.container().has( unit ):
		Debug.info( self, "Agent %s has no unit named %s" % [self.name, unit.name] )
	else:
		_controlled_units.remove( [unit] )


func getUnits() -> Array[UnitBase]:
	var units :Array[UnitBase] = []
	for unit in _controlled_units.container():
		units.append( unit )
	return units


func setProcessing( process : bool ):
	set_process_unhandled_input( process )
	set_physics_process( process )


func _setActive( unit : UnitBase ):
	if not _unitsInTree.has( unit ):
		_unitsInTree.append( unit )


func _setInactive( unit : UnitBase ):
	_unitsInTree.erase( _unitsInTree.find( unit ) )


func _update_active_units( units : Array ):
	var newUnitsInTree := []
	for activeUnit in _unitsInTree:
		if units.has( activeUnit ):
			newUnitsInTree.append( activeUnit )

	_unitsInTree = newUnitsInTree
	units_changed.emit( _controlled_units.container() )

