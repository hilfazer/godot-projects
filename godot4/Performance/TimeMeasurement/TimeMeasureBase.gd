extends Node
class_name MeasureBase


var loopCount : int = 10_000: set = setLoopCount


func measureTime() -> int:
	var msec := Time.get_ticks_msec()
	_execute()
	return Time.get_ticks_msec() - msec


func _execute():
	@warning_ignore("assert_always_false")
	assert(false)


func setup():
	pass


func teardown():
	pass


func setLoopCount(count : int):
	loopCount = count
