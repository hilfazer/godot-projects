extends TileMap

const FogVisionBaseGd        = preload("./FogVisionBase.gd")

enum TileType { Lit, Shaded, Fogged }

# warning-ignore:unused_class_variable
@export var fillTile: TileType

const lit_tile_id           := Vector2i(0, 2)
const shaded_tile_id        := Vector2i(0, 1)
const fogged_tile_id        := Vector2i(0, 0)
const _source_id            = 1
const layer                 = 0

var _fogVisionsToUpdate     := []
var _visionsToResults       := {}
var _doFogUpdate            := false

@onready var _updateTimer   = $"UpdateTimer"


func _ready():
	_updateTimer.connect("timeout", Callable(self, "requestFogUpdate"))
	_updateTimer.one_shot = true


func _physics_process( _delta ):
	if _doFogUpdate:
		_updateFog()
		_doFogUpdate = false


func requestFogUpdate():
	_doFogUpdate = true


func addFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( not fogVision in _visionsToResults )

# warning-ignore:return_value_discarded
	fogVision.connect("tree_exiting", Callable(self, "removeFogVision").bind(fogVision), CONNECT_ONE_SHOT)
# warning-ignore:return_value_discarded
	fogVision.connect("changedPosition", Callable(self, "onVisionChangedPosition").bind(fogVision))
	_insertFogVision( fogVision )
	_updateFog()
	return OK


func removeFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( fogVision in _visionsToResults )

	@warning_ignore("static_called_on_instance")
	_setTileInRect( shaded_tile_id, _visionsToResults[fogVision]["tileRect"], self )
	_eraseFogVision( fogVision )
	fogVision.disconnect("changedPosition", Callable(self, "onVisionChangedPosition"))
	_updateFog()
	return OK


func onVisionChangedPosition( fogVision : FogVisionBaseGd ):
	if _fogVisionsToUpdate.has( fogVision ):
		return

	_fogVisionsToUpdate.append( fogVision )
	if _fogVisionsToUpdate.size() == 1:
		_updateTimer.start( _updateTimer.wait_time )


func fillRectWithTile( rectangle : Rect2, type : int ):
	var typeToId = {
		  TileType.Lit : lit_tile_id
		, TileType.Shaded : shaded_tile_id
		, TileType.Fogged : fogged_tile_id
		}
	assert( type in typeToId )

	@warning_ignore("static_called_on_instance")
	_setTileInRect( typeToId[type], rectangle, self )


func getFogVisions() -> Array:
	return _visionsToResults.keys()


func serialize():
	var shadedTiles :Array[Vector2i] = get_used_cells_by_id( 0, _source_id, shaded_tile_id ) + \
		get_used_cells_by_id( 0, _source_id, lit_tile_id )
	var uncoveredArray := []

	for tileCoords in shadedTiles:
		uncoveredArray.append( int(tileCoords.x) )
		uncoveredArray.append( int(tileCoords.y) )

	return var_to_str( uncoveredArray )


func deserialize( data ):
	var uncoveredArray : PackedInt32Array = str_to_var( data )
	for i in uncoveredArray.size() / 2.0:
		var coords := Vector2i( uncoveredArray[i*2], uncoveredArray[i*2+1] )
		set_cell( 0, coords, -1, shaded_tile_id )


func _insertFogVision( fogVision : FogVisionBaseGd ):
	_visionsToResults[ fogVision ] = _makeVisionResult(
		fogVision.boundingRect( self ),
		fogVision.calculateVisibleTiles( self )
		)


func _eraseFogVision( fogVision : FogVisionBaseGd ):
	_visionsToResults.erase( fogVision )
	_fogVisionsToUpdate.erase( fogVision )


func _updateFog():
	#cover fog for nodes that moved
	for vision in _fogVisionsToUpdate:
		assert( vision is FogVisionBaseGd )
		_setTilesWithVisibilityMap(
			_visionsToResults[vision]["tileRect"],
			_visionsToResults[vision]["visibiltyMap"],
			shaded_tile_id
			)

	_fogVisionsToUpdate.clear()

	#uncover fog for every node
	for vision in _visionsToResults.keys():
		assert( vision is FogVisionBaseGd )
		var tileRect = vision.boundingRect( self )
		var visibilityMap = vision.calculateVisibleTiles( self )
		_setTilesWithVisibilityMap( tileRect, visibilityMap, lit_tile_id )

		_visionsToResults[ vision ] = _makeVisionResult( tileRect, visibilityMap )


func _makeVisionResult( tileRect : Rect2, visibiltyMap ):
	return { "tileRect" : tileRect, "visibiltyMap" : visibiltyMap }


func _setTilesWithVisibilityMap(
		tileRect : Rect2, visibiltyMap : PackedByteArray, tileId : Vector2i
		):
	var mapIdx = 0
	for x in range( tileRect.position.x, tileRect.size.x + tileRect.position.x):
		for y in range( tileRect.position.y, tileRect.size.y + tileRect.position.y):
			if visibiltyMap[mapIdx] != 0:
				set_cell(layer, Vector2i(x, y), _source_id, tileId)
			mapIdx += 1
	pass


static func _setTileInRect( tileId : Vector2i, rect : Rect2, fog : TileMap ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			fog.set_cell(layer, Vector2i(x, y), _source_id, tileId)


static func fogVisionFromNode( node : Node ) -> FogVisionBaseGd:
	for child in node.get_children():
		if child is FogVisionBaseGd:
			return child
	return null
