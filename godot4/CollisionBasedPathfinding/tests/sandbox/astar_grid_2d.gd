extends Node2D

var _path :PackedVector2Array = []


func _ready() -> void:
	var grid2d = AStarGrid2D.new()
	grid2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	grid2d.region = Rect2i(-20, -20, 300, 200)
	grid2d.cell_size = Vector2(8, 16)
	grid2d.update()
	
	print_debug(grid2d.is_in_bounds(-16, -16))
	
	_path = grid2d.get_point_path(Vector2i(-16,-16), Vector2(48, 8))


func _draw() -> void:
	_draw_path(_path)


func _draw_path( path ) -> void:
	for i in range(0, path.size() - 1):
		draw_line(Vector2(path[i].x, path[i].y), Vector2(path[i+1].x, path[i+1].y) \
			, Color.YELLOW, 1.5)
