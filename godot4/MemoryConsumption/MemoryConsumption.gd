extends VBoxContainer

const TypeLineGd = preload("res://AbstractTypeLine.gd")

@onready var spinAmount : SpinBox       = $"ObjectAmount/Amount"
@onready var typeLines : VBoxContainer  = $"Lines"


func _enter_tree():
	get_window().always_on_top = (true)


func _ready():
	for line in typeLines.get_children():
		assert( line is TypeLineGd )
		var ret = line.connect("typeToggled", Callable(self, "_onTypeToggled").bind(line))
		assert(ret == OK)


func _onTypeToggled( toggled : bool, line : TypeLineGd ):
	if toggled:
		line.create(int(spinAmount.value))
	else:
		line.destroy()
