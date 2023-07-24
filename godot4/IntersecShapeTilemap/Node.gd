extends Node


@onready var kinematic : CharacterBody2D = $'CharacterBody2D'


func _ready() -> void:
	call_deferred("check_intersections")


func check_intersections():
	var space_state := kinematic.get_world_2d().direct_space_state
	var character_shape_params = _createShapeQueryParameters(kinematic)
	print_collision(character_shape_params, space_state)

	character_shape_params.transform.origin = $'Static/StaticPosition'.global_position
	print_collision(character_shape_params, space_state)

	character_shape_params.transform.origin = $'TileMap/TilemapPosition'.global_position
	print_collision(character_shape_params, space_state)


static func _createShapeQueryParameters(body) -> PhysicsShapeQueryParameters2D:
	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_bodies = true
	params.collision_mask = body.collision_mask
	params.transform = body.transform
	params.exclude = [body] + body.get_collision_exceptions()
	params.shape = body.get_node("CollisionShape2D").shape
	return params


func print_collision( state_params : PhysicsShapeQueryParameters2D, space_state ):
	var intersect_shape_result = space_state.intersect_shape(state_params)
	var collide_shape_result = space_state.collide_shape(state_params)
	print('transform: ', state_params.transform.origin)
	print(intersect_shape_result)
	print(collide_shape_result)
	print('')
