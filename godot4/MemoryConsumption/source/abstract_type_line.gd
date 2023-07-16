@tool
extends HBoxContainer


var object_count := 0


signal type_toggled( toggled )


func _ready():
	$"ButtonType".toggled.connect( func(toggled: bool): type_toggled.emit(toggled) )


func _process(_delta):
	$"ButtonType".text = name


func create( count: int ) -> void:
	var err          = OK
	var static_start  = Performance.get_monitor(Performance.MEMORY_STATIC)

	var msec = Time.get_ticks_msec()

	err = _create(count)
	msec = Time.get_ticks_msec() - msec

	if err != OK:
		_destroy()
		return

	_setConstructionTime(msec)
	_setObjectCount(count)
	_setMemoryUsage(
		Performance.get_monitor(Performance.MEMORY_STATIC) - static_start,
		count
	)


func destroy() -> void:
	_destroy()
	_setObjectCount(0)
	_setMemoryUsage(0, object_count)


@warning_ignore("unused_parameter")
func _create( count: int ) -> int:
	assert(false)
	return ERR_DOES_NOT_EXIST


func _destroy():
	assert( false )


func _setMemoryUsage( static_usage: int, size_: int ):
	var total = max(static_usage, 0)
	$"MemoryTaken".text = String.humanize_size( total )
	var bytes_per_object = total / float(size_) if size_ != 0 else 0
	$"MemoryPerObject".text = "%.1f B" % bytes_per_object


func _setConstructionTime( time_ms: int ):
	var message = "time taken: %s ms"
	$"TimeTaken".text = message % [time_ms]


func _setObjectCount( count: int ):
	object_count = count
	$"Amount".text = str( count )
