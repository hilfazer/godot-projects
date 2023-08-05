extends RefCounted


static func createItemDb( ItemDbPath: String ) -> ItemDatabase:
	var databaseScene: ItemDatabase = load(ItemDbPath).new()
	var errors := []
	databaseScene.setupItemDatabase(errors)

	for error in errors:
		print(error)

	return databaseScene

