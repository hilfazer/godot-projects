extends "res://tests/gut_test_base.gd"

const FogTestingMaps = preload("res://tests/files/fog_of_war_testing_maps.tscn")


func test_make_fog_map_rect_from_tilemap():
	var maps = FogTestingMaps.instantiate()
	add_child_autofree(maps)
	var map16    :TileMapLayer = maps.get_node("TileMap16")
	var map32    :TileMapLayer = maps.get_node("TileMap32")
	var map32_x2 :TileMapLayer = maps.get_node("TileMap32_x2")

	var rect_map16 :Rect2i = FogOfWar.make_fog_map_rect_from_tilemap( \
			map16, Vector2i(16, 16) )
	assert_eq(rect_map16, Rect2i(2, 2, 5, 3))

	var rect_map32 :Rect2i = FogOfWar.make_fog_map_rect_from_tilemap( \
			map32, Vector2i(16, 16) )
	assert_eq(rect_map32, Rect2i(-4, -2, 6, 6))

	var rect_map32_x2 :Rect2i = FogOfWar.make_fog_map_rect_from_tilemap( \
			map32_x2, Vector2i(16, 16) )
	assert_eq(rect_map32_x2, Rect2i(4, -4, 8, 16))

	var rect_map16_fog64 :Rect2i = FogOfWar.make_fog_map_rect_from_tilemap( \
			map16, Vector2i(64, 64) )
	assert_eq(rect_map16_fog64, Rect2i())

	var rect_map32_fog8_16 :Rect2i = FogOfWar.make_fog_map_rect_from_tilemap( \
			map32, Vector2i(8, 16) )
	assert_eq(rect_map32_fog8_16, Rect2i(-8, -2, 12, 6))
