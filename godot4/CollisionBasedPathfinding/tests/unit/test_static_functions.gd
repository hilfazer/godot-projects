extends "res://tests/gut_test_base.gd"

const AStarBuilderGd =       preload("res://new_builder/collision_graph_builder.gd")
const StaticFunctionsGd =    preload("res://new_builder/static_functions.gd")
const RectCalcsGd =           preload("res://new_builder/rect_calculations.gd")
const PointsDataGd =         preload("res://new_builder/points_data.gd")

const PointsData =           PointsDataGd.PointsData


func test_calculateIdsForPoints():
	var pointsData := PointsData.create( \
			Vector2(16,16), Rect2(50,50,150,200), Vector2(12,12) )

	var pointsToIds = StaticFunctionsGd.calculateIdsForPoints( pointsData, Rect2(10,20,300,300) )
	assert_typeof(pointsToIds, TYPE_DICTIONARY)
	assert_eq(pointsToIds.size(), 9*12)
	assert_has(pointsToIds, Vector2(124,140))
	assert_has(pointsToIds, Vector2(60,60))
	assert_does_not_have(pointsToIds, Vector2(220,268))

	var negative = false
	for id in pointsToIds.values():
		if id < 0:
			negative = true
			break
	assert_false(negative)


func test_createConnectionsStraight():
	var pointsData := PointsData.create( \
			Vector2(24, 32), Rect2(0, 0, 48, 64), Vector2(10, 20))

	var connections = StaticFunctionsGd.createConnections(pointsData, false)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	assert_eq(connections.size(), connNum)
	assert_has(connections, [Vector2(10, 20), Vector2(34, 20)])
	assert_has(connections, [Vector2(10, 20), Vector2(10, 52)])
	assert_has(connections, [Vector2(34, 20), Vector2(34, 52)])
	assert_has(connections, [Vector2(10, 52), Vector2(34, 52)])
	assert_does_not_have(connections, [Vector2(-14, 20), Vector2(10, 20)])
	assert_does_not_have(connections, [Vector2(10, -12), Vector2(10, 20)])
	assert_does_not_have(connections, [Vector2(34, 52), Vector2(34, 84)])
	assert_does_not_have(connections, [Vector2(10, 20), Vector2(34, 52)])


func test_createConnectionsDiagonal():
	var pointsData := PointsData.create(Vector2(32, 32), Rect2(12, 36, 320, 320))
	var connections = StaticFunctionsGd.createConnections(pointsData, true)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	connNum += (pointsData.xCount-1) * (pointsData.yCount-1) * 2
	assert_eq(connections.size(), connNum)
	assert_has(connections, [Vector2(128, 256), Vector2(160, 288)])
	assert_does_not_have(connections, [Vector2(32, 32), Vector2(64, 64)])


enum Index { Step, Rect, Diagonal, PointsCount, Points, Connections }
const CreateFullyConnectedAStarParams = [
	[
		Vector2(20, 30),
		Rect2(20, 30, 160, 210),
		false,
		56,
		[Vector2(20,30), Vector2(40,90), Vector2(20,90), Vector2(160,210)],
		[2, 4, 3, 2],
	],
	[
		Vector2(20, 30),
		Rect2(20, 30, 160, 210),
		true,
		56,
		[Vector2(20,30), Vector2(40,90), Vector2(100,30), Vector2(160,210)],
		[3, 8, 5, 3],
	],
]

func test_createFullyConnectedAStar(prm = use_parameters(CreateFullyConnectedAStarParams)):
	var pointsData := PointsData.create( \
			prm[Index.Step], prm[Index.Rect])
	var pts2ids := StaticFunctionsGd.calculateIdsForPoints( pointsData )
	var astar : AStar2D = StaticFunctionsGd.createFullyConnectedAStar( \
			pointsData, pts2ids, prm[Index.Diagonal] )

	assert_eq(astar.get_point_count(), prm[Index.PointsCount])

	for i in prm[Index.Points].size():
		assert_eq(astar.get_point_connections( pts2ids[prm[Index.Points][i]] ).size(),
				prm[Index.Connections][i])
