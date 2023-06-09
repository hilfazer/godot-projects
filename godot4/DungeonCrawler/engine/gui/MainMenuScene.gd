extends Control

const NewGameScnPath         = "res://engine/gui/NewGameScene.tscn"
const LoadGameDialogScn      = preload("res://engine/gui/LoadGameDialog.tscn")


signal saveFileSelected( filepath )


func newGame():
	SceneSwitcher.switch_scene(NewGameScnPath)


func loadGame():
	var dialog = LoadGameDialogScn.instantiate()
	assert( not has_node( NodePath( dialog.get_name() ) ) )
	dialog.connect("file_selected", Callable(self, "onSaveFileSelected") )
	self.add_child (dialog )
	dialog.popup()
	dialog.connect("hide", Callable(dialog, "queue_free"))


func exitProgram():
	get_tree().quit()


func onSaveFileSelected( filepath : String ):
	emit_signal( "saveFileSelected", filepath )
