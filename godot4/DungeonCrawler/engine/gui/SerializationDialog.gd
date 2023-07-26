extends FileDialog

const SaveGameDirectory = "res://save"


func _ready() -> void:
	set_current_dir(SaveGameDirectory)
