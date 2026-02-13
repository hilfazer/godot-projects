extends "FogVisionBase.gd"


@export var _side := 8: set = setSide

var _rectOffset = Vector2( _side / 2.0, _side / 2.0 )


func allowInstantiation():
	pass


func calculateVisibleTiles(fogOfWar : TileMapLayer ) -> PackedByteArray:
	var rect = boundingRect( fogOfWar )

	var uncoveredIndices := PackedByteArray()
	uncoveredIndices.resize(_side*_side)
	for x in range(0, uncoveredIndices.size()):
		uncoveredIndices[x] = 1

	return uncoveredIndices


func boundingRect( fogOfWar : TileMapLayer ) -> Rect2:
	var rect = Rect2( 0, 0, _side, _side )
	var pos : Vector2 = fogOfWar.local_to_map( global_position )
	pos -= _rectOffset
	rect.position = pos
	return rect


func setSide( side : int ):
	_side = side if side % 2 == 0 else side + 1
