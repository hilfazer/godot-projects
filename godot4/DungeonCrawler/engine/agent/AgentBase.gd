extends Node
class_name AgentBase

const AgentMetaName = "agentRef"

var _units := SetWrapper.new()
var _unitsInTree := []


signal units_changed( units )


func _init():
# warning-ignore:return_value_discarded
	_units.changed.connect( Callable(self, "_update_active_units") )
	add_to_group( Globals.Groups.Agents )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for unit in _units.container():
			if is_instance_valid( unit ):
				unit.set_meta( AgentMetaName, null )


func addUnit( unit : UnitBase ) -> int:
	assert( unit != null )
	assert( not unit in _units.container() )

	if unit.has_meta( AgentMetaName ):
		var agent : AgentBase = unit.get_meta( AgentMetaName ).get_ref()

		if agent != null:
			var removed = agent.removeUnit( unit )
			assert( removed == true )
			Debug.info( self, "Removed agent %s from unit %s" % [agent.name, unit.name] )

	_units.add( [unit] )
# warning-ignore:return_value_discarded
	unit.tree_entered.connect(Callable(self, "_setActive").bind(unit))
# warning-ignore:return_value_discarded
	unit.tree_exited.connect(Callable(self, "_setInactive").bind(unit))
# warning-ignore:return_value_discarded
	unit.predelete.connect(Callable(self, "removeUnit").bind(unit), CONNECT_ONE_SHOT)
	if unit.is_inside_tree():
		_setActive( unit )

	unit.set_meta( AgentMetaName, weakref(self) )
	return OK


func removeUnit( unit : UnitBase ) -> bool:
	if not _units.container().has( unit ):
		Debug.info( self, "Agent %s has no unit named %s" % [self.name, unit.name] )
		return false

	_units.remove( [unit] )
	unit.tree_entered.disconnect(Callable(self, "_setActive"))
	unit.tree_exited.disconnect(Callable(self, "_setInactive"))
	unit.set_meta( AgentMetaName, null )
	return true


func getUnits() -> Array:
	return _units.container()


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
	units_changed.emit( _units.container() )

