extends Control

const NewGameScnPath         = "res://engine/gui/NewGameScene.tscn"
const SerializationDialogGd  = preload("res://engine/gui/SerializationDialog.gd")

@onready var load_dialog     : SerializationDialogGd = $'LoadGameDialog'


signal saveFileSelected( filepath )


func newGame():
	SceneSwitcher.switch_scene(NewGameScnPath)


func loadGame():
	load_dialog.popup()


func exitProgram():
	get_tree().quit()


func on_save_file_selected( filepath : String ):
	saveFileSelected.emit( filepath )
