extends Control

const LoadGameDialogScn      = preload("res://engine/gui/LoadGameDialog.tscn")
const SaveGameDialogScn      = preload("res://engine/gui/SaveGameDialog.tscn")


signal resumeSelected()
signal saveSelected( filepath )
signal loadSelected( filepath )
signal quitSelected()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


func onResumePressed():
	emit_signal("resumeSelected")


func onQuitPressed():
	emit_signal("quitSelected")


func onSavePressed():
	var dialog = SaveGameDialogScn.instantiate()
	assert( not has_node( NodePath( dialog.get_name() ) ) )
	dialog.connect("file_selected", Callable(self, "_onSaveFileSelected"))
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", Callable(dialog, "queue_free"))


func onLoadPressed():
	var dialog = LoadGameDialogScn.instantiate()
	assert( not has_node( NodePath( dialog.get_name() ) ) )
	dialog.connect("file_selected", Callable(self, "_onLoadFileSelected"))
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", Callable(dialog, "queue_free"))


func _onSaveFileSelected( filePath ):
	emit_signal( "saveSelected", filePath )


func _onLoadFileSelected( filePath ):
	emit_signal( "loadSelected", filePath )
