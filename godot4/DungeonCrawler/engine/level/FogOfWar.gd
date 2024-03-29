extends TileMap
class_name FogOfWar

enum TileType { Lit, Shaded, Fogged }

# warning-ignore:unused_class_variable
@export var fill_tile: TileType

const lit_tile_id           := Vector2i(2, 0)
const shaded_tile_id        := Vector2i(1, 0)
const fogged_tile_id        := Vector2i(0, 0)
const _source_id            = 1
const layer                 = 0

var _fog_visions_to_update  :Array[FogVisionBase] = []
var _visionsToResults       := {}
var _fog_update_requested   := false

@onready var _updateTimer   :Timer = $"UpdateTimer"


func _ready():
	_updateTimer.connect("timeout", Callable(self, "requestFogUpdate"))
	_updateTimer.one_shot = true


func _physics_process( _delta ):
	if _fog_update_requested:
		_updateFog()
		_fog_update_requested = false


func requestFogUpdate():
	_fog_update_requested = true


func addFogVision( fogVision : FogVisionBase ) -> Error:
	assert( fogVision )
	assert( not fogVision in _visionsToResults )

# warning-ignore:return_value_discarded
	fogVision.connect("tree_exiting", Callable(self, "removeFogVision").bind(fogVision), CONNECT_ONE_SHOT)
# warning-ignore:return_value_discarded
	fogVision.connect("changedPosition", Callable(self, "onVisionChangedPosition").bind(fogVision))
	_insertFogVision( fogVision )
	_updateFog()
	return OK


func removeFogVision( fogVision : FogVisionBase ) -> Error:
	assert( fogVision )
	assert( fogVision in _visionsToResults )

	@warning_ignore("static_called_on_instance")
	_setTileInRect( shaded_tile_id, _visionsToResults[fogVision]["tileRect"], self )
	_eraseFogVision( fogVision )
	fogVision.disconnect("changedPosition", Callable(self, "onVisionChangedPosition"))
	_updateFog()
	return OK


func onVisionChangedPosition( fogVision : FogVisionBase ):
	if _fog_visions_to_update.has( fogVision ):
		return

	_fog_visions_to_update.append( fogVision )
	if _fog_visions_to_update.size() == 1:
		_updateTimer.start( _updateTimer.wait_time )


func fill_tilemap_area_with_tile( tilemap : TileMap, type : TileType ):
	var typeToId = {
		  TileType.Lit : lit_tile_id
		, TileType.Shaded : shaded_tile_id
		, TileType.Fogged : fogged_tile_id
		}
	assert( type in typeToId )
	
	@warning_ignore("static_called_on_instance")
	var fog_rect = make_fog_map_rect_from_tilemap( tilemap, tile_set.tile_size )
	@warning_ignore("static_called_on_instance")
	_setTileInRect( typeToId[type], fog_rect, self )


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


func _insertFogVision( fogVision : FogVisionBase ):
	_visionsToResults[ fogVision ] = _makeVisionResult(
		fogVision.boundingRect( self ),
		fogVision.calculateVisibleTiles( self )
		)


func _eraseFogVision( fogVision : FogVisionBase ):
	_visionsToResults.erase( fogVision )
	_fog_visions_to_update.erase( fogVision )


func _updateFog():
	#cover fog for nodes that moved
	for vision in _fog_visions_to_update:
		assert( vision is FogVisionBase )
		_setTilesWithVisibilityMap(
			_visionsToResults[vision]["tileRect"],
			_visionsToResults[vision]["visibiltyMap"],
			shaded_tile_id
			)

	_fog_visions_to_update.clear()

	#uncover fog for every node
	for vision in _visionsToResults.keys():
		assert( vision is FogVisionBase )
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


static func fogVisionFromNode( node : Node ) -> FogVisionBase:
	for child in node.get_children():
		if child is FogVisionBase:
			return child
	return null


static func make_fog_map_rect_from_tilemap( tile_map :TileMap, fog_cell :Vector2i ) -> Rect2i:
	if tile_map.tile_set == null:
		return Rect2i()

	var scaled_map_cell : Vector2i = tile_map.tile_set.tile_size * Vector2i(tile_map.scale)

	if scaled_map_cell % fog_cell != Vector2i(0, 0):
		return Rect2i()
		
	var ratio = scaled_map_cell / fog_cell
	var fog_rect = tile_map.get_used_rect()
	fog_rect.position *= ratio
	fog_rect.size *= ratio
	return fog_rect
