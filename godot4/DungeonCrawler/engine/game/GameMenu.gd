extends Control

const SerializationDialogGd  = preload("res://engine/gui/SerializationDialog.gd")

@onready var save_dialog : SerializationDialogGd = $'SaveGameDialog'
@onready var load_dialog : SerializationDialogGd = $'LoadGameDialog'


signal resume_selected()
signal save_selected( filepath )
signal load_selected( filepath )
signal quit_selected()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


func onResumePressed():
	resume_selected.emit()


func onQuitPressed():
	quit_selected.emit()


func onSavePressed():
	save_dialog.popup()


func onLoadPressed():
	load_dialog.popup()


func _on_save_file_selected( filePath ):
	save_selected.emit( filePath )


func _on_load_file_selected( filePath ):
	load_selected.emit( filePath )
