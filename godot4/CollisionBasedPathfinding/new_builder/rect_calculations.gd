extends Object


func _init():
	@warning_ignore("assert_always_false")
	assert(false)


static func calculate_rect_from_tilemaps(
	tilemap_list :Array[TileMap], target_cell_size :Vector2i ) -> Rect2:
	
	var tilemap_rect :Rect2

	for tilemap in tilemap_list:
		assert(tilemap.scale == Vector2.ONE, "only supports scale of (1, 1)")
		var used_rect = tilemap.get_used_rect()
		var target_ratio :Vector2i = tilemap.tile_set.tile_size / target_cell_size
		var float_ratio := Vector2(tilemap.tile_set.tile_size) / Vector2(target_cell_size)
		if Vector2(target_ratio) != float_ratio:
			continue # skip maps that aren't divisible

		used_rect.position = used_rect.position * target_ratio
		used_rect.size = used_rect.size * target_ratio

		if tilemap_rect == Rect2():
			tilemap_rect = used_rect
		else:
			tilemap_rect = tilemap_rect.merge(used_rect)

	return tilemap_rect

