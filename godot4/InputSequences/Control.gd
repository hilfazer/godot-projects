extends Control

const m_sequences = {
	1 : ["ui_up", "ui_up", "ui_up"],
	2 : ["ui_up", "ui_up"],
	3 : ["ui_down"],
	4 : ["ui_down", "ui_up", "ui_down"],
	5 : ["ui_right", "ui_right"],
	6 : ["ui_right", "ui_left"],
	8 : ["ui_up", "ui_up", "ui_up"],
	9 : [],
}

const m_actions : Array[String] = ["ui_up", "ui_up", "ui_down", "ui_select", "ui_right", "ui_left"]

var m_detector = null


func _enter_tree():
	$"DetectorButtons".detectorSelected.connect( Callable(self, "setDetector") )
	$"DetectorButtons/CheckDetectorEnabled".connect("toggled", Callable(self, "onDetectingToggled"))


func _input(event):
	if event is InputEventKey and event.pressed:
		print( "pressed key keycode ", event.keycode )


func setDetector( path ) -> void:
	await get_tree().process_frame
	if m_detector:
		m_detector.free()

	var detector = load( path ).instantiate()
	add_child( detector )
	m_detector = detector

	m_detector.connect("sequenceDetected", Callable(self, "onSequenceDetected"))

	m_detector.setConsumingInput( $"DetectorButtons/CheckBoxConsume".button_pressed )
	$"DetectorButtons/CheckBoxConsume".toggled.connect( \
		Callable(m_detector, "setConsumingInput") )

	if $"DetectorButtons/CheckDetectorEnabled".button_pressed:
		m_detector.enable( $"DetectorButtons/CheckBoxInputType".button_pressed )
	else:
		m_detector.disable()

	$"DetectorButtons/CheckBoxInputType".connect("toggled", \
		Callable(m_detector, "enable") )

	$"AvailableSequences".clear()
	var discarded : Dictionary = m_detector.addSequences( m_sequences )
	for id in m_sequences:
		if id in discarded:
			print( discarded[id], " ", id, " ", m_sequences[id] )
		else:
			$"AvailableSequences".add_item( str(m_sequences[id]) )

	m_detector.addActions( m_actions )
	var ui_select : Array[String] = ["ui_select"]
	m_detector.removeActions( ui_select )


func onSequenceDetected( id : int ) -> void:
	$"PerformedSequences".add_item( str( m_sequences[id] ) )


func onDetectingToggled( pressed ) -> void:
	if not is_instance_valid( m_detector ):
		return

	if pressed:
		m_detector.enable( $"DetectorButtons/CheckBoxInputType".button_pressed )
	else:
		m_detector.disable()
