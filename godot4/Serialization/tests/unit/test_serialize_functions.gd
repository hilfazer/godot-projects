extends "res://tests/gut_test_base.gd"

const SerializerGd           = preload("res://hierarchical_serializer.gd")
const NodeGuardGd            = preload("res://node_guard.gd")
const FiveNodeBranchScn      = preload("res://tests/files/FiveNodeBranch.tscn")
const PostDeserializeScn     = preload("res://tests/files/PostDeserialize.tscn")
const BuiltInTypesScn        = preload("res://tests/files/BuiltInTypes.tscn")
const BuiltInTypesGd         = preload("res://tests/files/BuiltInTypes.gd")
const Scene1Scn              = preload("res://tests/files/Scene1.tscn")


func test_saveAndLoadWithoutParent():
	var branch = FiveNodeBranchScn.instantiate()
	var serializer : SerializerGd = SerializerGd.new()
	var saveFile = _createDefaultTestFilePath( _resourceExtension )
	var branchKey = "5NodeBranch"

	await get_tree().process_frame
	add_child( branch )

	branch.f = 4.4
	branch.s = "um"
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer").f = 0.0
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer/ColorRect").s = "7"
	@warning_ignore("unsafe_property_access")
	branch.get_node("Camera2D/Label").f = 3.3
	@warning_ignore("unsafe_property_access")
	branch.get_node("Camera2D/Label").i = 6

	var serializedBranch = serializer.serialize( branch )
	serializer.add_serialized( branchKey, serializedBranch )
	var err = serializer.save_to_file( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	serializer = SerializerGd.new()
	err = serializer.load_from_file( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.has_key(branchKey) )

	var serialized : Array = serializer.get_serialized( branchKey )
	assert_gt( serialized.size(), 0 )

	var guard : NodeGuardGd = serializer.get_and_deserialize( branchKey, null )
	assert_almost_eq( guard.node.get('f'), 4.4, EPSILON )
	assert_eq( guard.node.get('s'), "um" )
	assert_almost_eq( guard.node.get_node("Timer").get('f'), 0.0, EPSILON )
	assert_eq( guard.node.get_node("Timer/ColorRect").get('s'), "7" )
	assert_almost_eq( guard.node.get_node("Camera2D/Label").get('f'), 3.3, EPSILON )
	assert_eq( guard.node.get_node("Camera2D/Label").get('i'), 6 )
	guard.set_node(null)


func test_saveAndLoadToExistingBranch():
	var branch = FiveNodeBranchScn.instantiate()
	var serializer = SerializerGd.new()
	var saveFile = _createDefaultTestFilePath( "tres" )
	var branchKey = "5NodeBranch"

	await get_tree().process_frame
	add_child( branch )

	branch.s = "um"
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer").f = 0.0
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer/ColorRect").s = "7"

	serializer.add_and_serialize( branchKey, branch )
	var err = serializer.save_to_file( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	serializer = SerializerGd.new()
	err = serializer.load_from_file( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.has_key(branchKey) )

	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer").f = 99.99
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer/ColorRect").s = "7655"

	var serialized : Array = serializer.get_serialized( branchKey )
	assert_gt( serialized.size(), 0 )
	var node : Node = serializer.deserialize( serialized, self ).node
	assert_eq( node, branch )
	assert_eq( node.get('s'), "um" )
	assert_almost_eq( node.get_node("Timer").get('f'), 0.0, EPSILON )
	assert_eq( node.get_node("Timer/ColorRect").get('s'), "7" )


func test_saveAndLoadToNonexistingBranch():
	var branch = FiveNodeBranchScn.instantiate()
	var serializer = SerializerGd.new()
	var saveFile = _createDefaultTestFilePath( "tres" )
	var branchKey = "5NodeBranch"

	await get_tree().process_frame
	add_child( branch )

	branch.s = "v"
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer").f = 0.06
	@warning_ignore("unsafe_property_access")
	branch.get_node("Timer/ColorRect").s = "88"

	var serializedBranch = serializer.serialize( branch )
	serializer.add_serialized( branchKey, serializedBranch )
	var err = serializer.save_to_file( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	autofree( branch )
	remove_child( branch )
	assert( not is_ancestor_of( branch ) )

	err = serializer.load_from_file( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.has_key(branchKey) )

	var serialized : Array = serializer.get_serialized( branchKey )
	assert_gt( serialized.size(), 0 )

	var childrenNumber := get_child_count()
	var guard = serializer.deserialize( serialized, self )
	var node : Node = guard.node
	assert_eq( childrenNumber + 1, get_child_count() )
	assert_eq( node.get('s'), "v" )
	assert_almost_eq( node.get_node("Timer").get('f'), 0.06, EPSILON )
	assert_eq( node.get_node("Timer/ColorRect").get('s'), "88" )
	guard.set_node(null)


func test_postDeserialize():
	var serializer = SerializerGd.new()
	var node = autofree( PostDeserializeScn.instantiate() )
	node.set("i", 16)

	var serialized : Array  = serializer.serialize( node )
	var deserialized : Node = serializer.deserialize( serialized, self ).node

	assert_eq( deserialized.get("i"), 16 )
	assert_eq( deserialized.get("ii"), 16 )


func test_godotBuiltinTypes():
	var serializer = SerializerGd.new()
	var saveFile = _createDefaultTestFilePath( "tres" )
	var typesNode : BuiltInTypesGd = BuiltInTypesScn.instantiate()
	var key := "builtin"

	typesNode.b  = true
	typesNode.v2 = Vector2(3, 4.5)
	typesNode.r2 = Rect2(7, 6, 5, 4)
	typesNode.v3 = Vector3(.3, .4, .9)
	typesNode.t2 = Transform2D( 999, Vector2(5.5, 0) )
	typesNode.pl = Plane( Vector3(6, 7, .5), 44.44 )
	typesNode.q  = Quaternion(5, .11, 8, 3)
	typesNode.ab = AABB( Vector3(6, 71, .5), Vector3(66, 7, .5) )
	typesNode.ba = Basis( Vector3(.44, .001, 99), 0.0 )
	typesNode.t  = Transform3D( Quaternion(0, .11, 0, 3) )
	typesNode.co = Color(127, 255, 127, 20)
	typesNode.np = ^"path/to/the node"

	await get_tree().process_frame
	add_child( typesNode )

	serializer.add_and_serialize( key, typesNode )
	serializer.save_to_file( saveFile )
	serializer = SerializerGd.new()
	serializer.load_from_file( saveFile )

	var guard = serializer.get_and_deserialize( key, null )
	var node : BuiltInTypesGd = guard.node
	assert_eq( node.b , typesNode.b )
	assert_true( node.v2.is_equal_approx( typesNode.v2 ) )
	assert_true( node.r2.is_equal_approx( typesNode.r2 ) )
	assert_true( node.v3.is_equal_approx( typesNode.v3 ) )
	assert_true( node.t2.is_equal_approx( typesNode.t2 ) )
	assert_true( node.pl.is_equal_approx( typesNode.pl ) )
	assert_true( node.q .is_equal_approx( typesNode.q ) )
	assert_true( node.ab.is_equal_approx( typesNode.ab ) )
# workaround for bugged Basis.is_equal_approx()
	assert_true( node.ba.x.is_equal_approx( typesNode.ba.x ) )
	assert_true( node.ba.y.is_equal_approx( typesNode.ba.y ) )
	assert_true( node.ba.z.is_equal_approx( typesNode.ba.z ) )

	assert_true( node.t .is_equal_approx( typesNode.t ) )
	assert_true( node.co.is_equal_approx( typesNode.co ) )
	assert_eq( node.np, ^"path/to/the node" )

	guard.set_node( null )


func test_serializeNonserializableNode():
	var serializer = SerializerGd.new()
	var key = "n"
	var node = autofree( Node2D.new() )

	assert_false( serializer.add_and_serialize( key, node ) )
	assert_false( serializer.has_key( key) )


func test_deserializeNoninstantiable():
	pending()


func test_dynamicTree():
	pending()


func test_removeSerialized():
	var serializer = SerializerGd.new()
	var node = Scene1Scn.instantiate()

	assert_true( serializer.add_and_serialize("a", node ) )
	assert_true( serializer.remove_serialized("a") )
	assert_false( serializer.remove_serialized("a") )
	assert_false( serializer.remove_serialized("b") )

	node.free()

