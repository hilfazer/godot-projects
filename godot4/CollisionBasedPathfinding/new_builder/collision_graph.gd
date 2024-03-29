extends Node

const FunctionsGd =          preload("./static_functions.gd")
const PointsDataGd =         preload("./points_data.gd")

var astar2d : AStar2D
var _probe :CharacterBody2D
var _neighbourOffsets :Array
var _points2ids :Dictionary
var _pointsData :PointsDataGd.PointsData
var _shapeParams :PhysicsShapeQueryParameters2D


signal predelete()


func _init(
		  pointsData :PointsDataGd.PointsData
		, pts2ids :Dictionary
		, neighbourOffsets :Array
		):

	assert(neighbourOffsets.size() in [2, 4])
	assert(typeof(neighbourOffsets[1]) == TYPE_VECTOR2)

	name = "Graph"
	var diagonal = true if neighbourOffsets.size() == 4 else false
	astar2d = FunctionsGd.createFullyConnectedAStar(pointsData, pts2ids, diagonal)
	_neighbourOffsets = neighbourOffsets
	_points2ids = pts2ids
	_pointsData = pointsData


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal("predelete")


func initializeProbe(shape :RectangleShape2D, mask :int) -> void:
	@warning_ignore("static_called_on_instance")
	_probe = _createAndSetupProbe__(shape, mask)
	add_child(_probe)
	@warning_ignore("static_called_on_instance")
	_shapeParams = _createShapeQueryParameters(_probe)


func updateGraph(points :Array) -> void:
	if _probe == null:
		return

	@warning_ignore("static_called_on_instance")
	var ED_points = findEnabledAndDisabledPoints(points, _probe, _shapeParams)
	for pt in ED_points[0]:
		astar2d.set_point_disabled(_points2ids[pt], false)

	for pt in ED_points[1]:
		astar2d.set_point_disabled(_points2ids[pt], true)

	@warning_ignore("static_called_on_instance")
	var ED_connections = findEnabledAndDisabledConnections(
			points, ED_points[1], _probe, _shapeParams
			, _neighbourOffsets, _pointsData.boundingRect)

	for conn in ED_connections[0]:
		astar2d.connect_points(_points2ids[conn[0]], _points2ids[conn[1]])

	for conn in ED_connections[1]:
		astar2d.disconnect_points(_points2ids[conn[0]], _points2ids[conn[1]])


static func makeNeighbourOffsets(step :Vector2, diagonal :bool) -> Array:
	var offsets := [Vector2(step.x, 0), Vector2(0, step.y)]
	if diagonal:
		offsets += [Vector2(step.x, -step.y),Vector2(step.x, step.y)]
	return offsets


static func findEnabledAndDisabledPoints(
		points :Array, probe :CharacterBody2D, params :PhysicsShapeQueryParameters2D) -> Array:

	var enabledAndDisabled := [[], []]
	var spaceState := probe.get_world_2d().direct_space_state
	var transform := Transform2D()

	for pt in points:
		transform.origin = pt
		params.transform = transform
		var isValidPlace = spaceState.intersect_shape(params, 1).is_empty()
		enabledAndDisabled[ int(!isValidPlace) ].append(pt)

	return enabledAndDisabled


#ignores connections involving disabled points
static func findEnabledAndDisabledConnections(
		points :Array, disabledPoints :Array, probe :CharacterBody2D
		, params :PhysicsShapeQueryParameters2D, neighbourOffsets :Array, boundingRect :Rect2
		) -> Array:

	var disabledDict := {}  # for fast lookup
	for pt in disabledPoints:
		disabledDict[pt] = true

	var enabledAndDisabled := [[], []]
	var transform := Transform2D()

	for pt in points:
		for offset in neighbourOffsets:
			var targetPt : Vector2 = pt+offset
			if disabledDict.has(targetPt) or not boundingRect.has_point(targetPt):
				continue

			transform.origin = pt
			params.transform = transform

			var idx := int(probe.test_move(transform, offset))
			enabledAndDisabled[idx].append([pt, targetPt])

	return enabledAndDisabled


static func _createShapeQueryParameters(probe) -> PhysicsShapeQueryParameters2D:
	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_bodies = true
	params.collision_mask = probe.collision_mask
	params.transform = probe.transform
	params.exclude = [probe] + probe.get_collision_exceptions()
	params.shape = probe.get_node("CollisionShape2D").shape
	return params


static func _createAndSetupProbe__(shape :RectangleShape2D, mask :int) -> CharacterBody2D:
	var probe := CharacterBody2D.new()
	probe.name = "Probe"
	var collisionShape = CollisionShape2D.new()
	probe.add_child(collisionShape)
	collisionShape.name = "CollisionShape2D"
	collisionShape.shape = shape
	probe.collision_mask = mask
	return probe
