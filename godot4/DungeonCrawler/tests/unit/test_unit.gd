extends "res://tests/gut_test_base.gd"

const UnitBaseScn = preload("res://engine/units/UnitBase.tscn")

const _cell_size := Vector2i(32, 32)


func test_unit_make_movement_vector():
	var unit = UnitBaseScn.instantiate()
	get_tree().root.add_child(unit)
	unit.position = Vector2(32,32)
	var movement_vec = unit._makeMovementVector( Vector2i(1,0) )
	assert_eq(movement_vec, Vector2(32, 0))
	var target = Vector2i(unit.position.x + movement_vec.x, unit.position.y + movement_vec.y)
	assert_true( target.x % _cell_size.x == 0 )
	assert_true( target.y % _cell_size.y == 0 )
