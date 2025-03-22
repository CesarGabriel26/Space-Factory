extends BaseItemTransferBlock
class_name InternalItemUnloader

const ITEM_BOX = preload("res://resources/Entities/props/ItemBox/itemBox.tscn")

var target : BaseInventoryBlock
var loading_item_into_target = false

func _tick():
	get_item_from_container()
	move_item_out()
	pass

func instantiate_item_box(item_name : String, target_position : Vector2 , item_quantity : int = 1):
	var item : Sprite2D = ITEM_BOX.instantiate()
	add_child(item)
	item.texture = load("res://assets/textures/items/%s.png" % item_name)
	item.global_position = target_position
	item.item_name = item_name
	item.item_quantity = item_quantity
	receive_item(item)
	pass

func has_target():
	var target_poss : BaseBlock = null
	
	for check_pos in blockData.pointing_to:
		var found = MapDataManager.get_prop_at(check_pos + blockData.map_pos)
		if found and not typeof(found) == TYPE_DICTIONARY and not found is Drill:
			target_poss = found
	
	return target_poss != null

func get_item_from_container():
	if ItemPosition.get_child_count() > 0 or not has_target():
		return
	
	if not target:
		return
	
	if not target is BaseInventoryBlock:
		return
	
	if target.inventory_is_empty():
		return
	
	var item_data : Array = target.remove_item_from_last_slot()
	if item_data.is_empty():
		return
	
	instantiate_item_box(item_data[0], global_position)

func move_item_out():
	var target_poss : BaseBlock = null
	
	for check_pos in blockData.pointing_to:
		var found = MapDataManager.get_prop_at(check_pos + blockData.map_pos)
		if found and not typeof(found) == TYPE_DICTIONARY:
			target_poss = found
	
	if target_poss:
		move_item_to_target(target_poss)
