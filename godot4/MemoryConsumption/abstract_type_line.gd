@tool
extends HBoxContainer


var objectCount := 0


signal typeToggled( toggled )


func _ready():
	$"ButtonType".connect("toggled", Callable(self, "_emitTypeToggled"))


func _process(_delta):
	$"ButtonType".text = name


func create( count : int ) -> void:
	var err          = OK
	var staticStart  = Performance.get_monitor(Performance.MEMORY_STATIC)

	var msec = Time.get_ticks_msec()
	
	err = _create(count)
	msec = Time.get_ticks_msec() - msec

	if err != OK:
		_destroy()
		return

	_setConstructionTime(msec, count)
	_setObjectCount(count)
	_setMemoryUsage(
		Performance.get_monitor(Performance.MEMORY_STATIC) - staticStart,
		count
	)


func destroy() -> void:
	_destroy()
	_setObjectCount(0)
	_setMemoryUsage(0, objectCount)


@warning_ignore("unused_parameter")
func _create( count : int ) -> int:
	assert(false)
	return ERR_DOES_NOT_EXIST


func _destroy():
	assert( false )


func _setMemoryUsage( staticUsage : int, size_ : int ):
	var total = max(staticUsage, 0)
	$"MemoryTaken".text = String.humanize_size( total )
	var bytesPerObject = total / float(size_) if size_ != 0 else 0
	$"MemoryPerObject".text = "%.1f B" % bytesPerObject


func _setConstructionTime( timeMs : int, size_ : int ):
	var message = "creating %s: %s ms"
	$"TimeTaken".text = message % [size_, timeMs]


func _setObjectCount( count : int ):
	objectCount = count
	$"Amount".text = str( count )


func _emitTypeToggled( toggled : bool ):
	emit_signal("typeToggled", toggled)
