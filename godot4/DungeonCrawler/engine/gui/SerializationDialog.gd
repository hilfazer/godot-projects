extends FileDialog

#TODO saves in usr:// directory
const SaveGameDirectory = "res://save"


func _draw():
	set_current_dir(SaveGameDirectory)
