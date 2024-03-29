extends Node

const FunctionsGd =          preload("./static_functions.gd")
const RectCalcsGd =          preload("./rect_calculations.gd")
const PointsDataGd =         preload("./points_data.gd")
const GraphGd =              preload("./collision_graph.gd")

const MINIMUM_CELL_SIZE = Vector2(2, 2)
const ERR_UNINITIALIZED = -1
const ERR_INCORRECT_MASK = -2
const ERR_OUTSIDE_TREE = -3

var _pointsData : PointsDataGd.PointsData
var _pointsToIds : Dictionary
var _neighbourOffsets : Array

var _last_used_graph_id := 0
var _graphs := {}   # int (id) to Graph


signal graphDestroyed(graphId)


func _init():
	name = get_script().resource_path.get_basename().get_file()


func initialize(
		  cellSize :Vector2
		, boundingRect :Rect2
		, offset :Vector2 = Vector2()
		, isDiagonal :bool = false
		) -> int:

	if _pointsData:
		_printMessage("%s already initialized", [get_path() if is_inside_tree() else ^""])
		return ERR_ALREADY_EXISTS

	if cellSize.x < 1 or cellSize.y < 1:
		_printMessage("cellSize needs to be at least %s", [MINIMUM_CELL_SIZE])
		return ERR_CANT_CREATE

	if not boundingRect.has_area():
		_printMessage("bounding rectangle needs to have an area")
		return ERR_CANT_CREATE

	if offset.x < 0 or offset.y < 0:
		_printMessage("negative offset is not supported( %s )", [offset])
		return ERR_CANT_CREATE

	if offset.x >= cellSize.x or offset.y >= cellSize.y:
		_printMessage("offset values %s need to be lower than cellSize values %s", [offset, cellSize])
		return ERR_CANT_CREATE

	_pointsData = PointsDataGd.PointsData.create(cellSize, boundingRect, offset)
	assert(_pointsData)
	_neighbourOffsets = GraphGd.makeNeighbourOffsets(cellSize, isDiagonal)
	_pointsToIds = FunctionsGd.calculateIdsForPoints(_pointsData, boundingRect)
	return OK


func createGraph(unitShape :RectangleShape2D, collisionMask :int) -> int:
	if not _pointsData:
		_printMessage("can't create a graph - builder was not properly initialized")
		return ERR_UNINITIALIZED

	assert(_pointsData)
	assert(_pointsToIds)
	assert(_neighbourOffsets)

	if not collisionMask in range(1, 2<<20):
		_printMessage("can't create a graph - collision mask outside of (%s, %s) range", [1, 2<<20-1])
		return ERR_INCORRECT_MASK

	if not is_inside_tree():
		_printMessage("can't create a graph - builder is outside of SceneTree")
		return ERR_OUTSIDE_TREE

	var graph := GraphGd.new(_pointsData, _pointsToIds, _neighbourOffsets)
	add_child(graph)
	graph.initializeProbe(unitShape, collisionMask)

	graph.updateGraph( \
			RectCalcsGd.pointsFromRectangles([_pointsData.boundingRect], _pointsData).keys())

	var id = _last_used_graph_id + 1
	_last_used_graph_id += 1
	_graphs[id] = graph
	graph.predelete.connect(_onGraphPredelete.bind(id), CONNECT_ONE_SHOT)
	return id


func destroyGraph(graphId : int):
	if not graphId in _graphs.keys():
		_printMessage("There's no graph with ID %s", [graphId])
		return

	var graph = _graphs[graphId]
	var wasPresent = _graphs.erase(graphId)
	assert(wasPresent)
	graph.queue_free()
	remove_child(graph)


static func calculate_rect_from_tilemaps(
		tilemap_list :Array[TileMap], target_cell_size :Vector2i ) -> Rect2i:

	return RectCalcsGd.calculate_rect_from_tilemaps(tilemap_list, target_cell_size)


func _onGraphPredelete(graphId):
	emit_signal("graphDestroyed", graphId)


func getAStar2D(graphId :int) -> AStar2D:
	return _graphs[graphId].astar2d if _graphs.has(graphId) else null


func _printMessage( message :String, arguments :Array = []):
	print(name + " : " + message % arguments)
