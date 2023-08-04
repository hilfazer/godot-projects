extends Node

const GameScenePath          = "res://engine/game/GameScene.tscn"
const MainMenuPath           = "res://engine/gui/MainMenuScene.tscn"
const NewGameSceneGd         = preload("res://engine/gui/NewGameScene.gd")
const MainMenuSceneGd        = preload("res://engine/gui/MainMenuScene.gd")

const SCENE_CHANGE_FAILED    = "Failed to change scene to %s"

var _game : GameScene: set = _setGame


signal newGameSceneConnected( node )


func _init():
	set_process_mode( PROCESS_MODE_ALWAYS )
	name = get_script().resource_path.get_basename().get_file()


func _ready():
	@warning_ignore("return_value_discarded")
	SceneSwitcher.scene_set_as_current.connect(Callable(self, "_connectNewCurrentScene"))


func _connectNewCurrentScene():
	var newCurrent = get_tree().current_scene

	if newCurrent is NewGameSceneGd:
		@warning_ignore("return_value_discarded")
		newCurrent.connect("readyForGame", Callable(self, "_createGame").bind(), CONNECT_ONE_SHOT)
		@warning_ignore("return_value_discarded")
		newCurrent.connect("finished", Callable(self, "_toMainMenu").bind(), CONNECT_ONE_SHOT)

		newGameSceneConnected.emit( newCurrent )

	elif newCurrent is MainMenuSceneGd:
		@warning_ignore("return_value_discarded")
		newCurrent.connect("saveFileSelected", Callable(self, "_loadGame").bind(), CONNECT_ONE_SHOT)

	elif newCurrent is GameScene:
		assert( _game == null )
		_setGame( get_tree().current_scene )
		@warning_ignore("return_value_discarded")
		_game.connect("gameFinished", Callable(self, "onGameEnded").bind(), CONNECT_ONE_SHOT)
		@warning_ignore("return_value_discarded")
		_game.connect("nonmatching_save_file_selected", Callable(self, "_makeGameFromFile").bind(), CONNECT_ONE_SHOT)


func _toMainMenu():
	var error :Error = SceneSwitcher.switch_scene( MainMenuPath )

	if error:
		print(SCENE_CHANGE_FAILED % MainMenuPath)


func _createGame( module_, playerUnitsCreationData : Array ):
	var error :Error = SceneSwitcher.switch_scene( GameScenePath,
		{
			GameScene.Params.Module : module_,
			GameScene.Params.PlayerUnitsData : playerUnitsCreationData,
		},
		Constants.Meta.SwitchParams )
		
	if error:
		print(SCENE_CHANGE_FAILED % GameScenePath)


func onGameEnded():
	assert( _game )
	_toMainMenu()
	_setGame( null )


func _setGame( gameScene : GameScene ):
	assert( gameScene == null or _game == null )
	_game = gameScene


func _loadGame( filePath : String ):
	assert(not _isGameInProgress())

	var error :Error = SceneSwitcher.switch_scene( GameScenePath,
		{ GameScene.Params.SaveFileName : filePath }, Constants.Meta.SwitchParams )

	if error:
		print(SCENE_CHANGE_FAILED % GameScenePath)


func _isGameInProgress() -> bool:
	return _game != null \
		&& not get_tree().current_scene is GameScene


func _makeGameFromFile( filePath : String ):
	_setGame( null )

	var error :Error = SceneSwitcher.switch_scene( GameScenePath,
		{ GameScene.Params.SaveFileName : filePath }, Constants.Meta.SwitchParams )

	if error:
		print(SCENE_CHANGE_FAILED % GameScenePath)
