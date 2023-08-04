extends CanvasLayer

var _display_variables : Dictionary

@onready var _variable_list : ItemList = $'Variables'


func _ready():
	refresh_variable_view()


func _on_PrintSceneTree_pressed():
	$"/root".print_tree_pretty()


func _on_PrintStrayNodes_pressed():
	Node.print_orphan_nodes()


func setVariables( variables : Dictionary ):
	_display_variables = variables
	refresh_variable_view()


func refresh_variable_view():
	_variable_list.clear()
	@warning_ignore("return_value_discarded")
	_variable_list.add_item("  VARIABLE")
	@warning_ignore("return_value_discarded")
	_variable_list.add_item("  VALUE")

	for variable in _display_variables:
		@warning_ignore("return_value_discarded")
		_variable_list.add_item(str(variable))
		@warning_ignore("return_value_discarded")
		_variable_list.add_item(str(_display_variables[variable]))
