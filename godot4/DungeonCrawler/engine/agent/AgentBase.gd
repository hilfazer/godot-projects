extends Node
class_name AgentBase


var _controlled_units := SetWrapper.new()
var units_in_tree := []:
	get:
		return _controlled_units.container().filter( func(a): return a.is_inside_tree() )


signal units_changed( units )


func _init():
	add_to_group( Constants.Groups.Agents )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for unit in _controlled_units.container():
			if is_instance_valid( unit ):
				unit.set_meta( Constants.Meta.Agent, null )


func addUnit( unit : UnitBase ) -> Error:
	assert( unit != null )
	if unit in _controlled_units.container():
		return ERR_ALREADY_EXISTS

	if unit.has_meta( Constants.Meta.Agent ):
		var agent : AgentBase = unit.get_meta( Constants.Meta.Agent ).get_ref()

		if agent != null:
			var removed = agent.removeUnit( unit )
			assert( removed == true )
			Debug.info( self, "Removed agent %s from unit %s" % [agent.name, unit.name] )

	_controlled_units.add( [unit] )
	unit.predelete.connect(Callable(self, "remove_deleted_unit").bind(unit), CONNECT_ONE_SHOT)

	unit.set_meta( Constants.Meta.Agent, weakref(self) )
	return OK


func removeUnit( unit : UnitBase ) -> Error:
	if not _controlled_units.container().has( unit ):
		Debug.info( self, "Agent %s has no unit named %s" % [self.name, unit.name] )
		return ERR_DOES_NOT_EXIST

	_controlled_units.remove( [unit] )
	unit.set_meta( Constants.Meta.Agent, null )
	return OK


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
