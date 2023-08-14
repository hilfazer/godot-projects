extends TileMap

# warning-ignore:unused_class_variable
@export var step := Vector2(32, 32)
# warning-ignore:unused_class_variable
@export var pointsOffset := Vector2(0,0)
# warning-ignore:unused_class_variable
@export var diagonal : bool
# warning-ignore:unused_class_variable
@onready var boundingRect := _calculateSectorRect([self])


func _calculateSectorRect( tilemapList : Array[TileMap] ) -> Rect2:
	var levelRect : Rect2

	for tilemap in tilemapList:
		var usedRect = tilemap.get_used_rect()
		var tilemapTargetRatio = Vector2(tilemap.tile_set.tile_size) * tilemap.scale
		usedRect.position *= Vector2i(tilemapTargetRatio)
		usedRect.size *= Vector2i(tilemapTargetRatio)

		if not levelRect:
			levelRect = usedRect
		else:
			levelRect = levelRect.merge(usedRect)

	return levelRect
