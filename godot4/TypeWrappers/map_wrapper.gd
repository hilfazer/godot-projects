extends RefCounted
class_name MapWrapper

var _dict = {}


signal changed( dict )


func _init( dict = {} ):
	_dict = dict


func reset( dict ):
	if _dict == dict:
		return

	_dict = dict
	changed.emit( _dict )

# doesn't alter values of existing keys
func add( dict ):
	var size = _dict.size()
	for x in dict:
		if not x in _dict:
			_dict[x] = dict[x]

	if _dict.size() > size:
		changed.emit( _dict )

# alters values of existing keys, doesn't add new keys
func replace( dict ):
	var changed = false
	for x in dict:
		if x in _dict and _notEqual( _dict[x], dict[x] ):
			_dict[x] = dict[x]
			changed = true

	if changed:
		changed.emit( _dict )

# alters values of existing keys, can add new keys
func addReplace( dict ):
	var changed = false
	for x in dict:
		if not x in _dict or _notEqual(_dict[x], dict[x]):
			_dict[x] = dict[x]
			changed = true

	if changed:
		changed.emit( _dict )


func remove( array ):
	var size = _dict.size()
	for x in array:
		_dict.erase( x )

	if _dict.size() < size:
		changed.emit( _dict )


func copy() -> MapWrapper:
	return load( get_script().resource_path).new( _dict.duplicate(true) )


func container() -> Dictionary:
	return _dict


static func _notEqual( a, b ):
	return typeof(a) != typeof(b) or a != b
