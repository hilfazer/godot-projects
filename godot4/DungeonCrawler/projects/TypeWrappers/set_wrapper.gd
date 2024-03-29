extends RefCounted
class_name SetWrapper

var _array = []


signal changed( array )


func _init( array = [] ):
	@warning_ignore("static_called_on_instance")
	var uniqueArray = unique( array )
	assert( array == uniqueArray )
	_array = uniqueArray


func reset( array ):
	if _array == array:
		return

	@warning_ignore("static_called_on_instance")
	var uniqueArray = unique( array )
	assert( array == uniqueArray )
	_array.resize( uniqueArray.size() )
	for i in range( array.size() ):
		_array[i] = array[i]
	changed.emit( _array )


func add( array ):
	var size = _array.size()
	for x in array:
		if not x in _array:
			_array.append( x )

	if _array.size() > size:
		changed.emit( _array )


func remove( array ):
	var size = _array.size()
	for x in array:
		_array.erase( x )

	if _array.size() < size:
		changed.emit( _array )


func copy() -> SetWrapper:
	return load( get_script().resource_path).new( _array.duplicate(true) )


func container() -> Array:
	return _array


static func unique( array : Array ) -> Array:
	var b := []
	for x in array:
		if not x in b:
			b.append( x )
	return b
