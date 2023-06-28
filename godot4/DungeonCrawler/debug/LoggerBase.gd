extends RefCounted

var _logLevel := 2: set = setLogLevel


func setLogLevel( level : int ):
	_logLevel = level


@warning_ignore("unused_parameter")
func info( caller : Object, message : String ):
	pass


@warning_ignore("unused_parameter")
func warn( caller : Object, message : String ):
	pass


@warning_ignore("unused_parameter")
func error( caller : Object, message : String ):
	pass
