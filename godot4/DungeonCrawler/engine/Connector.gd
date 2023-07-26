extends Node

const GameScenePath          = "res://engine/game/GameScene.tscn"
const MainMenuPath           = "res://engine/gui/MainMenuScene.tscn"
const GameSceneGd            = preload("./game/GameScene.gd")
const NewGameSceneGd         = preload("res://engine/gui/NewGameScene.gd")
const MainMenuSceneGd        = preload("res://engine/gui/MainMenuScene.gd")

var _game : GameSceneGd: set = _setGame


signal newGameSceneConnected( node )


func _init():
	set_process_mode( PROCESS_MODE_ALWAYS )
	name = get_script().resource_path.get_basename().get_file()


func _ready():
# warning-ignore:return_value_discarded
	SceneSwitcher.scene_set_as_current.connect(Callable(self, "_connectNewCurrentScene"))


func _connectNewCurrentScene():
	var newCurrent = get_tree().current_scene

	if newCurrent is NewGameSceneGd:
		newCurrent.connect("readyForGame", Callable(self, "_createGame").bind(), CONNECT_ONE_SHOT)
		newCurrent.connect("finished", Callable(self, "_toMainMenu").bind(), CONNECT_ONE_SHOT)

		emit_signal( "newGameSceneConnected", newCurrent )

	elif newCurrent is MainMenuSceneGd:
		newCurrent.connect("saveFileSelected", Callable(self, "_loadGame").bind(), CONNECT_ONE_SHOT)

	elif newCurrent is GameSceneGd:
		assert( _game == null )
		_setGame( get_tree().current_scene )
# warning-ignore:return_value_discarded
		_game.connect("gameFinished", Callable(self, "onGameEnded").bind(), CONNECT_ONE_SHOT)
# warning-ignore:return_value_discarded
		_game.connect("nonmatching_save_file_selected", Callable(self, "_makeGameFromFile").bind(), CONNECT_ONE_SHOT)


func _toMainMenu():
	SceneSwitcher.switch_scene( MainMenuPath )


func _createGame( module_, playerUnitsCreationData : Array ):
	SceneSwitcher.switch_scene( GameScenePath,
		{
			GameSceneGd.Params.Module : module_,
			GameSceneGd.Params.PlayerUnitsData : playerUnitsCreationData,
		},
		GameSceneGd.PARAMS_META )


func onGameEnded():
	assert( _game )
	_toMainMenu()
	_setGame( null )


func _setGame( gameScene : GameSceneGd ):
	assert( gameScene == null or _game == null )
	_game = gameScene


func _loadGame( filePath : String ):
	assert(not _isGameInProgress())

	SceneSwitcher.switch_scene( GameScenePath,
		{ GameSceneGd.Params.SaveFileName : filePath }, GameSceneGd.PARAMS_META )


func _isGameInProgress() -> bool:
	return _game != null \
		&& not get_tree().current_scene is GameSceneGd


func _makeGameFromFile( filePath : String ):
	_setGame( null )

	SceneSwitcher.switch_scene( GameScenePath,
		{ GameSceneGd.Params.SaveFileName : filePath }, GameSceneGd.PARAMS_META )
