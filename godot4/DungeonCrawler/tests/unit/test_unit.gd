extends "res://tests/gut_test_base.gd"

const UnitBaseScn = preload("res://engine/units/UnitBase.tscn")


func test_unit_make_movement_vector():
	var unit = UnitBaseScn.instantiate()
	get_tree().root.add_child(unit)
	unit.position = Vector2(32,32)
	var movement_vec = unit._makeMovementVector( Vector2i(1,0) )
	assert_eq(movement_vec, Vector2(16, 0))
	var target = Vector2i(unit.position.x + movement_vec.x, unit.position.y + movement_vec.y)
	assert_eq( target.x % Constants.GRID_STEP.x, 0 )
	assert_eq( target.y % Constants.GRID_STEP.y, 0 )
