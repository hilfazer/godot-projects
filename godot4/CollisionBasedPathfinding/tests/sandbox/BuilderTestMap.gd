extends CanvasItem

const GraphBuilderGd         = preload("res://new_builder/collision_graph_builder.gd")
const UnitGd                 = preload("./Unit.gd")
const SectorGd               = preload("./sector.gd")

@export var _draw_points := true
@export var _draw_path := true

var _astarDataDict := {}
var _graphId : int = -1
var _path : PackedVector2Array

@onready var _sector :SectorGd = $"Sector1"
@onready var _unit :UnitGd = $"Sector1/Unit"
@onready var graph_builder :GraphBuilderGd = $"Sector1/GraphBuilder"


func _ready():
	var graphBuilder :GraphBuilderGd = _sector.get_node("GraphBuilder")
	var step :Vector2 = _sector.step
	var boundingRect = GraphBuilderGd.calculateRectFromTilemaps([_sector], step)

	var err = graphBuilder.initialize(step, boundingRect, _sector.pointsOffset, _sector.diagonal)
	assert(err == OK)
	var mask = 2
	_graphId = graphBuilder.createGraph(_unit.get_node("CollisionShape2D").shape, mask)
	


func _unhandled_input(event :InputEvent) -> void:
	if event is InputEventMouse:
		var newPath := _findPath(_sector)
		if newPath != _path:
			_path = newPath
			queue_redraw()

	if event.is_action_pressed("moveUnit") and _path:
		_unit.followPath(_path)


func _draw():
	var astar :AStar2D = graph_builder.getAStar2D(_graphId)
	if astar == null:
		return

	if _draw_points:
		for id in astar.get_point_ids():
			draw_circle(astar.get_point_position(id), 1, Color.CYAN)
			
	if _draw_path:
		draw_polyline(_path, Color.YELLOW, 1.2)


func _findPath(sector : SectorGd) -> PackedVector2Array:
	var path := PackedVector2Array()
	path.resize(0)
	var astar : AStar2D = graph_builder.getAStar2D(_graphId)
	var startPoint = _unit.global_position
	var endPoint = get_viewport().get_mouse_position()
	var startId = astar.get_closest_point( Vector2(startPoint.x, startPoint.y) )
	var endId = astar.get_closest_point( Vector2(endPoint.x, endPoint.y) )
	path = astar.get_point_path(startId, endId)
	return path
