extends VBoxContainer

const LongestSequenceDetectorPath = "res://LongestSequenceDetector.tscn"
const SubsequenceDetectorPath = "res://SubsequenceDetector.tscn"

signal detectorSelected( path )


func _ready():
	$"ButtonLongest".button_down.connect( \
		Callable(self, "emit_signal").bind("detectorSelected", LongestSequenceDetectorPath) )
	$"ButtonSubsequence".button_down.connect( \
		Callable(self, "emit_signal").bind("detectorSelected", SubsequenceDetectorPath) )

	emit_signal("detectorSelected", SubsequenceDetectorPath)
	$"ButtonSubsequence".set_pressed_no_signal( true )
