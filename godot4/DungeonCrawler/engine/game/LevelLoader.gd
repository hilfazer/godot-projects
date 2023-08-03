extends RefCounted

enum State { Ready, Loading, Unloading }

const TRANSITION_ZONES = "TransitionZones"
const TRANSITION_NAME_NOT_SPECIFIED = "Level transition zone name unspecified. Using first zone found."
const TRANSITION_NAME_NOT_FOUND = "Level transition zone name not found. Using first zone found."

var _game : GameScene
var _level_file_path : String
var _state : State = State.Ready


func _init( game : GameScene ):
	_game = game


func loadLevel( level_file_path : String, levelParent : Node ) -> Error:
	assert( _game._state == _game.State.Creating )
	assert( _game.is_ancestor_of( levelParent ) or _game == levelParent )
	assert( level_file_path.is_absolute_path() )

	if _state != State.Ready:
		Debug.warn(self, "LevelLoader not ready to load %s" % level_file_path)
		return ERR_UNAVAILABLE

	_changeState(State.Loading, level_file_path)
	var retval = await _loadLevel(level_file_path, levelParent)
	_changeState(State.Ready)
	return retval


func _loadLevel( level_file_path : String, levelParent : Node ) -> Error:
	await _game.get_tree().process_frame
	var levelResource = load( level_file_path )
	if not levelResource:
		Debug.error( self, "Could not load level file: " + level_file_path )
		return ERR_CANT_CREATE

	var level : LevelBase = levelResource.instantiate()

	if _game.currentLevel != null:
		var result = await _unloadLevel(_game.currentLevel)
		assert( result == OK )

	assert( not _game.has_node( NodePath(level.name) ) )
	levelParent.add_child( level )
	_game.setCurrentLevel( level )

	assert( level.is_inside_tree() )
	assert( _game.currentLevel == level )
	return OK


func unloadLevel() -> Error:
	if( not _state == State.Ready ):
		return ERR_UNAVAILABLE

	assert( _game.currentLevel )
	var level : LevelBase = _game.currentLevel

	_changeState( State.Unloading, level.scene_file_path )
	var retval :Error = await _unloadLevel(level)
	_changeState( State.Ready )
	return retval


func _unloadLevel( level : LevelBase ) -> Error:
	await _game.get_tree().process_frame
	var levelUnits = level.getAllUnits()
	for playerUnit in _game.get_player_units():
		if playerUnit in levelUnits:
			Debug.info( self, "Player unit '%s' will be destroyed with level '%s'" %
				[ playerUnit.name, level.name ] )

	level.queue_free()
	await level.predelete
	await _game.get_tree().process_frame
	assert( not is_instance_valid( level ) )
	_game.setCurrentLevel( null )
	return OK


static func insertPlayerUnits( \
		playerUnits : Array, level : LevelBase, transition_zone_name : String ) -> Array:

	var spawns = get_spawns_from_transition_zone( level, transition_zone_name )
	var notAdded := []

	for unit in playerUnits:
		assert( unit is UnitBase and is_instance_valid(unit) )
		var freeSpawn = findFreePlayerSpawn(spawns)
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		unit.set_position(freeSpawn.global_position)
		var added = level.addUnit(unit) == OK
		if not added:
			notAdded.append(unit)

	return notAdded


static func get_spawns_from_transition_zone( level : LevelBase, transition_zone_name : String ) -> Array:
	var spawns := []
	var transitionZone :Area2D

	if transition_zone_name == null:
		Debug.info(level, TRANSITION_NAME_NOT_SPECIFIED)
		transitionZone = level.get_node(TRANSITION_ZONES).get_child(0)
	else:
		transitionZone = level.get_node(TRANSITION_ZONES).get_node(transition_zone_name)
		if transitionZone == null:
			Debug.warn(level, TRANSITION_NAME_NOT_FOUND)
			transitionZone = level.get_node(TRANSITION_ZONES).get_child(0)

	assert( transitionZone != null )
	for child in transitionZone.get_children():
		if child.is_in_group( Constants.Groups.SpawnPoints ):
			spawns.append( child )

	return spawns


static func findFreePlayerSpawn( spawns : Array ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null


func _changeState( state : State, level_file_path : String = "" ):
	match( state ):
		_state:
			Debug.warn(self, "changing to same state")
			return
		State.Ready:
			assert( level_file_path.is_empty() )
		State.Loading:
			assert( not level_file_path.is_empty() )
		State.Unloading:
			assert( not level_file_path.is_empty() )

	_level_file_path = level_file_path
	_state = state
