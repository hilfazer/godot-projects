@tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(ArrayDoubleIndexing.new(), "ArrayDoubleIndexing")
	addMeasure(ArraySingleIndexing.new(), "ArraySingleIndexing")
	addMeasure(ArrayWithEnumKeys.new(), "ArrayWithEnumKeys")
	addMeasure(DictionaryWithStringKeys.new(), "DictionaryWithStringKeys")
	addMeasure(DictionaryWithStringNameKeys.new(), "DictionaryWithStringNameKeys")


class BaseWith2DArray extends MeasureBase:
	var array = []

	func setLoopCount(count : int):
		super.setLoopCount(count)

		var inner = []
		inner.resize(int(sqrt(loopCount)))
		array.resize(int(sqrt(loopCount)))

		for i in array.size():
			array[i] = inner.duplicate()


class ArrayDoubleIndexing extends BaseWith2DArray:
	func _execute():
		for i in array.size():
			for j in array[i].size():
				@warning_ignore("standalone_expression")
				array[i][j]


class ArraySingleIndexing extends BaseWith2DArray:
	func _execute():
		for i in array.size():
			var inner : Array = array[i]
			for j in inner.size():
				@warning_ignore("standalone_expression")
				inner[j]


enum Keys { One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten }
const StringKeys :Array[String] = [
	'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten']
const StringNameKeys :Array[StringName] = [
	&'One', &'Two', &'Three', &'Four', &'Five', &'Six', &'Seven', &'Eight', &'Nine', &'Ten']


class ArrayWithEnumKeys extends MeasureBase:
	var array := []
	var keysToCheck := []


	func _init():
		for i in Keys.size():
			array.append(StringKeys[i])


	func setLoopCount(count : int):
		super.setLoopCount(count)

		keysToCheck.resize(count)
		for i in count:
			keysToCheck[i] = Keys.values()[ randi() % Keys.size() ]


	func _execute():
		for key in keysToCheck:
			@warning_ignore("standalone_expression")
			array[key]


class DictionaryWithStringKeys extends MeasureBase:
	var dict := {}
	var keysToCheck := []


	func _init():
		for i in Keys.size():
			dict[StringKeys[i]] = StringKeys[i]


	func setLoopCount(count : int):
		super.setLoopCount(count)

		keysToCheck.resize(count)
		for i in count:
			keysToCheck[i] = StringKeys[ randi() % StringKeys.size() ]


	func _execute():
		for key in keysToCheck:
			@warning_ignore("standalone_expression")
			dict[key]


class DictionaryWithStringNameKeys extends MeasureBase:
	var dict := {}
	var keysToCheck := []


	func _init():
		for i in Keys.size():
			dict[StringNameKeys[i]] = StringNameKeys[i]


	func setLoopCount(count : int):
		super.setLoopCount(count)

		keysToCheck.resize(count)
		for i in count:
			keysToCheck[i] = StringNameKeys[ randi() % StringNameKeys.size() ]


	func _execute():
		for key in keysToCheck:
			@warning_ignore("standalone_expression")
			dict[key]
