extends RefCounted


var name : String: set = deleted
var icon : Texture2D: set = deleted


func deleted(_a):
	assert(false)


func _init( name_ : String, icon_ : Texture2D ):
	name = name_
	icon = icon_
