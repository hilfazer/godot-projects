extends HBoxContainer


func _process(_delta):
	$"LineStatic".text  = \
		String.humanize_size( Performance.get_monitor(Performance.MEMORY_STATIC) )
