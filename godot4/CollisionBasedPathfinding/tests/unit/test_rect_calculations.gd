extends "res://tests/gut_test_base.gd"

const RectCalculationsGd = preload("res://new_builder/rect_calculations.gd")
const TilemapsForRectCalculationScn = preload("res://tests/files/tilemaps_for_rect_calculation.tscn")


class TestRectFromTilemaps extends "res://tests/gut_test_base.gd":
	const Params := [
		[ Vector2i(16, 16), ["16", "32_16", "64"], Rect2(-4, -3, 8, 11) ],
		[ Vector2i(16, 16), ["16", "32_16"], Rect2(-4, -3, 8, 6) ],
		[ Vector2i(32, 32), ["16", "32_16", "64"], Rect2(0, 2, 2, 2) ],
		[ Vector2i(1, 1), [], Rect2(0, 0, 0, 0) ],
	]

	func test_calculate_rect_from_tilemaps( prm = use_parameters(Params) ):
		var scene :Node = autofree(TilemapsForRectCalculationScn.instantiate())
		
		var tilemaps :Array[TileMap]
		for map_name in prm[1]:
			tilemaps.append(scene.get_node(map_name))

		var rect = RectCalculationsGd.calculate_rect_from_tilemaps(tilemaps, prm[0])
		assert_eq(rect, prm[2])
