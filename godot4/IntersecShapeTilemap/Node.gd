extends Node


@onready var kinematic : CharacterBody2D = $'CharacterBody2D'


func _ready() -> void:
	call_deferred("check_intersections")


func check_intersections():
	var character_shape_params = _createShapeQueryParameters(kinematic)
	var space_state := kinematic.get_world_2d().direct_space_state

	var result1 = space_state.intersect_shape(character_shape_params)
	print('transform: ', character_shape_params.transform.origin)
	print(result1)

	character_shape_params.transform.origin = $'Static/StaticPosition'.global_position
	var result2 = space_state.intersect_shape(character_shape_params)
	print('transform: ', character_shape_params.transform.origin)
	print(result2)
	
	character_shape_params.transform.origin = $'TileMap/TilemapPosition'.global_position
	var result3 = space_state.intersect_shape(character_shape_params)
	print('transform: ', character_shape_params.transform.origin)
	print(result3)


static func _createShapeQueryParameters(body) -> PhysicsShapeQueryParameters2D:
	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_bodies = true
	params.collision_mask = body.collision_mask
	params.transform = body.transform
	params.exclude = [body] + body.get_collision_exceptions()
	params.shape = body.get_node("CollisionShape2D").shape
	return params
