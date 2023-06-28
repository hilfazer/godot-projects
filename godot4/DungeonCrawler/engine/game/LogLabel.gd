extends Label


func setMessage( message : String ):
	self.text = message

	if has_node("resetMessage"):
		$"resetMessage".start()
	else:
		var timer = Timer.new()
		timer.name = "resetMessage"
		timer.connect("timeout", Callable(self, "set_text").bind(""))
		timer.connect("timeout", Callable(timer, "queue_free"))
		timer.wait_time = 3
		add_child( timer )
		timer.start()

