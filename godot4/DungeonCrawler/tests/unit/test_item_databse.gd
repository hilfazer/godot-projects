extends "res://tests/gut_test_base.gd"


const ItemFactoryGd          = preload("res://engine/items/item_factory.gd")

const Db1Directory = "res://tests/files/items/db1/"

const DB1_ITEM_IDS := ["helm01", "helm02", "club"]

func test_create_item_database():
	var item_db1 :ItemDatabase = ItemFactoryGd.create_item_database(Db1Directory)
	
	if item_db1 == null:
		fail_test("failed to create item db")
		return

	assert_eq(item_db1.item_count(), DB1_ITEM_IDS.size())

	for item_id in DB1_ITEM_IDS:
		assert_not_null(item_db1.get_item_by_id(item_id))
