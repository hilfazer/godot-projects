extends VBoxContainer

const TypeLineGd = preload("res://abstract_type_line.gd")

@onready var spinAmount: SpinBox       = %Amount
@onready var typeLines: Container  = $"TypeLines"


func _enter_tree():
	get_window().always_on_top = true


func _ready():
	for line in typeLines.get_children():
		assert( line is TypeLineGd )
		var ret = line.connect("typeToggled", Callable(self, "_onTypeToggled").bind(line))
		assert(ret == OK)


func _onTypeToggled( toggled: bool, line: TypeLineGd ):
	if toggled:
		line.create(int(spinAmount.value))
	else:
		line.destroy()
