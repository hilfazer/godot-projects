extends CanvasLayer

const GameMenuScn            = preload("GameMenu.tscn")
const GameMenuGd             = preload("res://engine/game/GameMenu.gd")

var _gameMenu : GameMenuGd
@onready var _game : GameScene        = get_parent()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()


func toggleGameMenu():
	if _gameMenu == null:
		createGameMenu()
	else:
		deleteGameMenu()


func createGameMenu():
	assert( _gameMenu == null )
	var gameMenu = GameMenuScn.instantiate()
	self.add_child( gameMenu )
	gameMenu.visibility_changed.connect(Callable(_game, "setPause").bind(gameMenu.visible))
	gameMenu.tree_exiting.connect(Callable(_game, "setPause").bind(false))
	gameMenu.resume_selected.connect(Callable(self, "_resume"))
	gameMenu.save_selected.connect(Callable(self, "_saveGame"))
	gameMenu.load_selected.connect(Callable(self, "_loadGame"))
	gameMenu.quit_selected.connect(Callable(self, "_quit"))
	_gameMenu = gameMenu


func deleteGameMenu():
	assert( _gameMenu != null )
	_gameMenu.queue_free()
	_gameMenu = null


func _resume():
	deleteGameMenu()


func _saveGame( filepath : String ):
	deleteGameMenu()
	_game.saveGame( filepath )


func _loadGame( filepath : String ):
	_gameMenu.disconnect("tree_exiting", Callable(_game, "setPause"))
	deleteGameMenu()
	_game.loadGame( filepath )


func _quit():
	_gameMenu.disconnect("tree_exiting", Callable(_game, "setPause"))
	_game.finish()
