extends "./LoggerBase.gd"


var _file : FileAccess


func _init( filename : String ):
	var directory = DirAccess.open( filename.get_base_dir() )
	if not directory.dir_exists( filename.get_base_dir() ):
		directory.make_dir_recursive( filename.get_base_dir() )

	var logFile = FileAccess.open(filename, FileAccess.WRITE)

	assert( null != logFile )
	_file = logFile


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_file.close()


func info( _caller : Object, message : String ):
	if _logLevel >= 3:
		_file.store_line( "INFO | %s" % [message] )


func warn( _caller : Object, message : String ):
	if _logLevel >= 2:
		_file.store_line( "WARN | %s" % [message] )


func error( _caller : Object, message : String ):
	if _logLevel >= 1:
		_file.store_line( "ERROR| %s" % [message] )
