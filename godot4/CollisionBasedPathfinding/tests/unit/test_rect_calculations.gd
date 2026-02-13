extends "res://tests/gut_test_base.gd"

const RectCalcsGd = preload("res://new_builder/rect_calculations.gd")
const TilemapsForRectCalculationScn = preload("res://tests/files/tilemaps_for_rect_calculation.tscn")
const PointsDataGd =         preload("res://new_builder/points_data.gd")

const PointsData =           PointsDataGd.PointsData


func test_pointsFromRect():
	var pointsData := PointsData.create(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect := Rect2(65, 65, 65, 65)
	var points := RectCalcsGd.pointsFromRect( rect, pointsData )

	assert_eq( points.size(), 9 )
	assert_has( points, Vector2(90, 90) )
	assert_has( points, Vector2(70, 110) )
	assert_does_not_have( points, Vector2(130, 130) )
	assert_does_not_have( points, Vector2(20, 20) )


func test_pointsFromRectangles():
	var pointsData := PointsData.create(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect1 := Rect2(65, 65, 65, 65)
	var rect2 := Rect2(-50, 0, 80, 66)
	var arr :Array[Rect2] = [rect1, rect2]
	var points := RectCalcsGd.pointsFromRectangles( arr, pointsData )

	assert_eq(points.size(), 9 + 3)




class TestRectFromTilemaps extends "res://tests/gut_test_base.gd":
	const Params := [
		[ Vector2i(16, 16), ["16", "32_16", "64"], Rect2i(-64, -48, 129, 177) ],
		[ Vector2i(16, 16), ["16", "32_16"], Rect2i(-64, -48, 129, 97) ],
		[ Vector2i(32, 32), ["16", "32_16", "64"], Rect2i(0, 64, 65, 65) ],
		[ Vector2i(1, 1), [], Rect2i(0, 0, 1, 1) ],
	]

	func test_calculate_rect_from_tilemaps( prm = use_parameters(Params) ):
		var scene :Node = autofree(TilemapsForRectCalculationScn.instantiate())
		
		var tilemaps :Array[TileMapLayer] = []
		for map_name in prm[1]:
			tilemaps.append(scene.get_node(map_name))

		var rect = RectCalcsGd.calculate_rect_from_tilemaps(tilemaps, prm[0])
		assert_typeof(rect, TYPE_RECT2I)
		assert_eq(rect, prm[2])
