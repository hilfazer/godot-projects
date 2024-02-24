extends Control

const Script_path = 'res://static/static_variables.gd'


func _on_write_pressed() -> void:
	load_script().static_var = $'ValueWrite'.text


func _on_read_pressed() -> void:
	$'ValueRead'.text = str( load_script().static_var )


func load_script():
	return load(Script_path)
