extends HBoxContainer


func _process(_delta):
	$"LineStatic".text  = \
		String.humanize_size( int(Performance.get_monitor(Performance.MEMORY_STATIC)) )
