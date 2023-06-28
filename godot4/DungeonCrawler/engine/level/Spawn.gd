extends Marker2D

var _bodiesInArea = 0


func _ready():
	assert(  is_in_group(Globals.Groups.SpawnPoints) )
	_bodiesInArea = get_node("Area2D").get_overlapping_bodies().size()


func spawnAllowed():
	assert( _bodiesInArea >= 0 )
	return _bodiesInArea == 0


func onArea2DBodyEntered( _body ):
	_bodiesInArea += 1


func onArea2DBodyExited( _body ):
	_bodiesInArea -= 1

