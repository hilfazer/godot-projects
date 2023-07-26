extends CanvasLayer

const GameMenuScn            = preload("GameMenu.tscn")
const GameMenuGd             = preload("res://engine/game/GameMenu.gd")
const GameSceneGd            = preload("res://engine/game/GameScene.gd")

var _gameMenu : GameMenuGd
@onready var _game : GameSceneGd        = get_parent()


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
	gameMenu.connect("visibility_changed", Callable(_game, "setPause").bind(gameMenu.visible))
	gameMenu.connect("tree_exiting", Callable(_game, "setPause").bind(false))
	gameMenu.connect("resume_selected", Callable(self, "_resume"))
	gameMenu.connect("save_selected", Callable(self, "_saveGame"))
	gameMenu.connect("load_selected", Callable(self, "_loadGame"))
	gameMenu.connect("quit_selected", Callable(self, "_quit"))
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
