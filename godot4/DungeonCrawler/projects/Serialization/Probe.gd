extends RefCounted

const SerializerGd           = preload("./hierarchical_serializer.gd")

static func scan( node : Node ) -> Probe:
	return Probe.new( node )



class Probe extends RefCounted:
	# deserialize( node ) can only add nodes via scene instancing
	# creation of other nodes needs to be taken care of outside of
	# deserialize( node ) (i.e. _init(), _ready())
	# or deserialize( node ) won't deserialize them nor their branch
	var nodes_not_instantiable : Array[Node]
	var nodes_no_matching_deserialize : Array[Node]


	func _init( node : Node ):
		if node.owner == null and node.scene_file_path.is_empty():
			_add_not_instantiable( node )

		if node.has_method(SerializerGd.SERIALIZE) \
				and not node.has_method(SerializerGd.DESERIALIZE):
			_add_no_matching_deserialize( node )

		for child in node.get_children():
			_merge( Probe.new( child ) )


	func _merge( other : Probe ):
		for i in other.nodes_not_instantiable:
			nodes_not_instantiable.append( i )
		for i in other.nodes_no_matching_deserialize:
			nodes_no_matching_deserialize.append( i )


	func _add_not_instantiable( node : Node ):
		if nodes_not_instantiable.find( node ) == -1:
			nodes_not_instantiable.append( node )


	func _add_no_matching_deserialize( node : Node ):
		if nodes_no_matching_deserialize.find( node ) == -1:
			nodes_no_matching_deserialize.append( node )
