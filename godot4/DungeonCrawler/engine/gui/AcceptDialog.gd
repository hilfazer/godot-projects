

static func showAcceptDialog( message, title, dialogParent ):
	var dialog = AcceptDialog.new()
	dialog.set_title( title )
	dialog.set_text( message )
	dialog.set_name( title )
	dialog.exclusive = false
	dialog.connect("confirmed", Callable(dialog, "queue_free"))
	dialog.connect("hide", Callable(dialog, "queue_free"))
	dialog.connect("tree_entered", Callable(dialog, "call_deferred").bind("popup_centered_clamped"))
	SceneSwitcher.connect("scene_set_as_current", Callable(dialog, "raise"))
	dialogParent.call_deferred("add_child", dialog)
