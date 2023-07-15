extends VBoxContainer

const TypeLineGd = preload("res://abstract_type_line.gd")

@export var _line_containers : Array[Control] = []

@onready var _spin_amount: SpinBox       = %'Amount'


func _enter_tree():
	get_window().always_on_top = true


func _ready():
	for line in get_type_lines():
		assert( line is TypeLineGd )
		var ret = line.connect("typeToggled", Callable(self, "_onTypeToggled").bind(line))
		assert(ret == OK)


func _onTypeToggled( toggled: bool, line: TypeLineGd ):
	if toggled:
		line.create(int(_spin_amount.value))
	else:
		line.destroy()


func get_type_lines() -> Array[TypeLineGd]:
	var lines: Array[TypeLineGd] = []
	
	for container in _line_containers:
		for line in container.get_children():
			if line is TypeLineGd:
				lines.append(line)
	return lines
	
	
