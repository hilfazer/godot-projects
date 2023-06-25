extends Node


static func getEnabledPoints(astar : AStar2D) -> PackedInt32Array:
	var enabledPoints := PackedInt32Array()
	for point in astar.get_point_ids():
		if not astar.is_point_disabled(point):
			enabledPoints.append(point)
	return enabledPoints


static func calculateEdgeCountInRect(x :int, y :int, diagonal :bool) -> int:
	return x * (y - 1) + y * (x - 1) + int(diagonal) * 2 * (x - 1) * (y - 1)
