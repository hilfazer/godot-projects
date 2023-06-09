extends Panel

const PlayerString = "%s (%s) %s"

var _maxUnits = 0: set = setMaxUnits


func refreshLobby( clientList : Dictionary ):
	$"Players/PlayerList".clear()
	for pId in clientList:
		var playerString = PlayerString % [clientList[pId], pId, ""]
		$"Players/PlayerList".add_item( playerString )


func setMaxUnits( maxUnits : int ):
	_maxUnits = maxUnits
	$"UnitLimit".setMaximum( maxUnits )
