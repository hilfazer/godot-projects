extends "./LoggerBase.gd"


var _file : FileAccess


func _init( filename : String ):
	var directory = DirAccess.open( filename.get_base_dir() )
	if not directory.dir_exists( filename.get_base_dir() ):
		var err = directory.make_dir_recursive( filename.get_base_dir() )
		if err:
			print("Failed to create a directory for a log file %s" % filename)
			return

	var logFile = FileAccess.open(filename, FileAccess.WRITE)

	assert( null != logFile )
	_file = logFile


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_file.close()


func info( _caller : Object, message : String ):
	if not _file.is_open():
		return

	if _logLevel >= 3:
		_file.store_line( "INFO | %s" % [message] )


func warn( _caller : Object, message : String ):
	if not _file.is_open():
		return

	if _logLevel >= 2:
		_file.store_line( "WARN | %s" % [message] )


func error( _caller : Object, message : String ):
	if not _file.is_open():
		return

	if _logLevel >= 1:
		_file.store_line( "ERROR| %s" % [message] )
