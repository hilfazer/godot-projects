extends "res://tests/gut_test_base.gd"

const UnitBaseScn = preload("res://engine/units/UnitBase.tscn")

func test_add_unit():
	var agent :AgentBase = add_child_autofree( AgentBase.new() )
	var unit1 = add_child_autofree( UnitBaseScn.instantiate() )
	var unit2 = add_child_autofree( UnitBaseScn.instantiate() )
	var agent_units :Array = []

	agent.addUnit( unit1 )
	agent_units = agent.getUnits()
	assert_eq(agent_units.size(), 1)
	assert_has(agent_units, unit1)

	agent.addUnit( unit2 )
	agent_units = agent.getUnits()
	assert_eq(agent_units.size(), 2)
	assert_has(agent_units, unit1)
	assert_has(agent_units, unit2)
	
	var unit1added = agent.addUnit(unit1)
	assert_eq(unit1added, ERR_ALREADY_EXISTS)
	assert_eq(agent_units.size(), 2)


func test_remove_unit():
	var agent :AgentBase = add_child_autofree( AgentBase.new() )
	var unit1 = add_child_autofree( UnitBaseScn.instantiate() )
	var unit2 = add_child_autofree( UnitBaseScn.instantiate() )
	var agent_units :Array = []

	agent.addUnit( unit1 )
	agent.addUnit( unit2 )
	var unit1removed :Error = agent.removeUnit( unit1 )
	agent_units = agent.getUnits()
	assert_eq(unit1removed, OK)
	assert_eq(agent_units.size(), 1)
	assert_does_not_have(agent_units, unit1)
	assert_has(agent_units, unit2)

	unit1removed = agent.removeUnit(unit1)
	assert_eq(unit1removed, ERR_DOES_NOT_EXIST)


func test_units_in_tree_get():
	var agent :AgentBase = add_child_autofree( AgentBase.new() )
	var unit1 = add_child_autofree( UnitBaseScn.instantiate() )
	var unit2 = add_child_autofree( UnitBaseScn.instantiate() )
	var units_in_tree := []
	
	agent.addUnit(unit1)
	agent.addUnit(unit2)
	units_in_tree = agent.units_in_tree
	assert_eq(units_in_tree.size(), 2)
	assert_has(units_in_tree, unit1)
	assert_has(units_in_tree, unit2)

	agent.removeUnit(unit2)
	units_in_tree = agent.units_in_tree
	assert_eq(units_in_tree.size(), 1)
	assert_has(units_in_tree, unit1)
	assert_does_not_have(units_in_tree, unit2)
