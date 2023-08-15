extends Object

const PointsDataGd =         preload("./points_data.gd")

const PointsData =           PointsDataGd.PointsData


func _init():
	@warning_ignore("assert_always_false")
	assert(false)


static func calculate_rect_from_tilemaps(
	tilemap_list :Array[TileMap], target_cell_size :Vector2i ) -> Rect2i:
	
	var rect := Rect2i()

	for tilemap in tilemap_list:
		assert(tilemap.scale == Vector2.ONE, "only supports scale of (1, 1)")
		var used_rect = tilemap.get_used_rect()
		var target_ratio :Vector2i = tilemap.tile_set.tile_size / target_cell_size
		var float_ratio := Vector2(tilemap.tile_set.tile_size) / Vector2(target_cell_size)
		if Vector2(target_ratio) != float_ratio:
			continue # skip maps that aren't divisible

		used_rect.position = used_rect.position * target_ratio
		used_rect.size = used_rect.size * target_ratio

		if rect == Rect2i():
			rect = used_rect
		else:
			rect = rect.merge(used_rect)

	rect.position *= target_cell_size
	rect.size *= target_cell_size
	return rect



static func pointsFromRect( rectangle :Rect2, pointsData :PointsData ) -> Array:
	var rect := rectangle.intersection(pointsData.boundingRect)
	var step = pointsData.step
	var topLeft = (rect.position).snapped(step)
	topLeft += pointsData.offset
	topLeft.x = topLeft.x if topLeft.x >= rect.position.x else topLeft.x + step.x
	topLeft.y = topLeft.y if topLeft.y >= rect.position.y else topLeft.y + step.y
	if topLeft.x - step.x >= rect.position.x:
		topLeft.x -= step.x
	if topLeft.y - step.y >= rect.position.y:
		topLeft.y -= step.y

	var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - topLeft.x
	var xCount = int(xFirstToRectEnd / step.x) + 1

	var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - topLeft.y
	var yCount = int(yFirstToRectEnd / step.y) + 1

	var points := []
	for x in range(topLeft.x, topLeft.x + xCount * step.x, step.x):
		for y in range(topLeft.y, topLeft.y + yCount * step.y, step.y):
			points.append( Vector2(x, y) )

	return points


static func pointsFromRectangles( rectangles :Array, pointsData :PointsData ) -> Dictionary:
	var points := {}

	for rect in rectangles:
		assert( rect is Rect2 )
		for pt in pointsFromRect(rect, pointsData):
			points[pt] = true

	return points
