extends VBoxContainer

const LongestSequenceDetectorPath = "res://LongestSequenceDetector.tscn"
const SubsequenceDetectorPath = "res://SubsequenceDetector.tscn"

#warning-ignore:unused_signal
signal detectorSelected( path )


func _ready():
	$"ButtonLongest".button_down.connect( \
		Callable(self, "emit_signal").bind("detectorSelected", LongestSequenceDetectorPath) )
	$"ButtonSubsequence".button_down.connect( \
		Callable(self, "emit_signal").bind("detectorSelected", SubsequenceDetectorPath) )


#	var evmb := InputEventMouseButton.new()
#	evmb.button_index = MOUSE_BUTTON_LEFT
#	evmb.pressed = true
#	$"ButtonSubsequence"._gui_input(evmb)
#
#	evmb = InputEventMouseButton.new()
#	evmb.button_index = MOUSE_BUTTON_LEFT
#	evmb.pressed = false
#	$"ButtonSubsequence"._gui_input(evmb)
