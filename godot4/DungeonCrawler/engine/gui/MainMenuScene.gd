extends Control

const NewGameScnPath         = "res://engine/gui/NewGameScene.tscn"
const LoadGameDialogScn      = preload("res://engine/gui/LoadGameDialog.tscn")


signal saveFileSelected( filepath )


func newGame():
	SceneSwitcher.switch_scene(NewGameScnPath)


func loadGame():
	var dialog = LoadGameDialogScn.instantiate()
	var dialog_name := NodePath( dialog.get_name() )
	assert( not has_node( dialog_name ) )
	dialog.connect("file_selected", Callable(self, "onSaveFileSelected") )
	self.add_child (dialog )
	dialog.popup()
	dialog.visibility_changed.connect(Callable(dialog, "queue_free") )


func exitProgram():
	get_tree().quit()


func onSaveFileSelected( filepath : String ):
	emit_signal( "saveFileSelected", filepath )
