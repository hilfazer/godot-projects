extends VBoxContainer

const NewGameSceneGd = preload("res://engine/gui/NewGameScene.gd")

const UnitCreatorName = "UnitCreator"

var _mainMenu


func _ready():
	_mainMenu = get_parent()
	_mainMenu.get_node("Buttons/NewGame").connect("pressed", Callable(self, "deleteCreator"))


func newCreator():
	var unitCreator = UnitCreator.new()
	unitCreator.name = UnitCreatorName
# warning-ignore:return_value_discarded
	$"/root/Connector".connect("newGameSceneConnected", Callable(unitCreator, "connectOnReady"))

	deleteCreator()
	$"/root".add_child( unitCreator )


func deleteCreator():
	if not $"/root".has_node( UnitCreatorName ):
		return

	var creator = $"/root".get_node( UnitCreatorName )
	Utility.setFreeing( creator )


func _on_NewCreateButton_pressed():
	newCreator()
	_mainMenu.newGame()


class UnitCreator extends Node:
	var CharacterCreationScn   = preload("res://engine/gui/CharacterCreation.tscn")

	func connectOnReady( new_game_scene :NewGameSceneGd ):
		new_game_scene.connect("ready", Callable(self, "createUnit").bind(new_game_scene))

	func createUnit( new_game_scene :NewGameSceneGd ):
		if is_queued_for_deletion():
			return

		var characterCreation = CharacterCreationScn.instantiate()
		add_child(characterCreation)
		characterCreation.queue_free()
		if new_game_scene.get_module() != null:
			characterCreation.initialize( new_game_scene.get_module() )
			var character_data = characterCreation.makeCharacter()
			new_game_scene.get_node( "UnitsManager" ).createCharacter( character_data )

		self.queue_free()
