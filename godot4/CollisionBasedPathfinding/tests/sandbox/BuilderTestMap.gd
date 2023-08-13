extends CanvasItem

const GraphBuilderGd         = preload("res://new_builder/collision_graph_builder.gd")
const UnitGd                 = preload("./Unit.gd")
const SectorGd               = preload("./sector.gd")

@export var _drawEdges := false
@export var _drawPoints := false

var _astarDataDict := {}
@onready var _sector = $"Sector1"
var _graphId : int = -1


func _ready():
	var unit : CharacterBody2D = _sector.get_node("Unit")
	var graphBuilder : GraphBuilderGd = _sector.get_node("GraphBuilder")
	var step : Vector2 = _sector.step
	var boundingRect = GraphBuilderGd.calculateRectFromTilemaps([_sector], step)

	graphBuilder.initialize(step, boundingRect, _sector.pointsOffset, _sector.diagonal)
	var mask = 2
	_graphId = graphBuilder.createGraph(_sector.get_node("Unit/CollisionShape2D").shape, mask)


func _draw():
	var astar : AStar2D = _sector.get_node("GraphBuilder").getAStar2D(_graphId)
	if astar == null:
		return

	if _drawPoints:
		for id in astar.get_point_ids():
			draw_circle(astar.get_point_position(id), 1, Color.CYAN)

# TODO draw edges
#	if _drawEdges:
#		for id in astar.get_points():
#			draw_circle(astar.get_point_position(id), 1, Color.cyan)

