extends BaseItemTransferBlock
class_name ItemLu

const ITEM_BOX = preload("res://resources/Entities/props/ItemBox/itemBox.tscn")


var loading_item_into_target = false

func _ready() -> void:
	MapDataManager.tick.connect(_tick)
	self.pointingTo_and_mapPos_updated.connect(_set_rotation)
	_set_rotation()

func _set_rotation():
	match blockData.pointing_to:
		Vector2.RIGHT:
			ModelspritesNode.rotation_degrees = 90
		Vector2.DOWN:
			ModelspritesNode.rotation_degrees = 180
		Vector2.LEFT:
			ModelspritesNode.rotation_degrees = -90
		Vector2.UP:
			ModelspritesNode.rotation_degrees = 0

func _tick():
	if blockData.get('is_preview') : return
	
	if blockData.action_type == "unload":
		if ItemPosition.get_child_count() == 0:
			get_item_from_container()
		else:
			move_item_to_target()
	else:
		if ItemPosition.get_child_count() == 0:
			get_item_from_conveyor()
		else:
			load_item_into_target()

#### usado em itemLu no modo unload

func instantiate_item_box(item_name : String, target_position : Vector2 , item_quantity : int = 1):
	var item : Sprite2D = ITEM_BOX.instantiate()
	add_child(item)
	item.texture = load("res://assets/textures/items/%s.png" % item_name)
	item.global_position = target_position
	item.item_name = item_name
	item.item_quantity = item_quantity
	receive_item(item)
	pass

func get_item_from_container():
	# inventer o pointing_to para obter a direção oposta a que esta apontando, assim obtendo o bloco atras do itemLU
	var target = MapDataManager.get_prop_at(
		blockData.map_pos + (blockData.pointing_to * - 1)
	)
	
	if not target:
		return
	
	if not target is BaseInventoryBlock and typeof(target) != TYPE_DICTIONARY:
		return
	
	var target_Pos : Vector2
	if typeof(target) == TYPE_DICTIONARY:
		target_Pos = get_parent().map_to_local(blockData.map_pos + (blockData.pointing_to * - 1))
		target = target.get("occupied_by")
	else:
		target_Pos = target.global_position
	
	if target.inventory_is_empty():
		return
	
	var item_data : Array = target.remove_item_from_last_slot()
	if item_data.is_empty():
		return
	
	instantiate_item_box(item_data[0], target_Pos)

#### usado em itemLu no modo load
func get_item_from_conveyor():
	var target = MapDataManager.get_prop_at(
		blockData.map_pos + (blockData.pointing_to * -1)
	)
	
	if not target:
		return
	
	if not target is Conveyor:
		return
	target.move_item_to_target(self)

func load_item_into_target():
	var item  = ItemPosition.get_child(0)
	
	if item.global_position != ItemPosition.global_position and not loading_item_into_target:
		return
	
	var target = MapDataManager.get_prop_at(
		blockData.map_pos + blockData.pointing_to
	)
	
	if not target:
		return
	
	if not target is BaseInventoryBlock:
		return
	
	if not target.can_add_item(item.item_name):
		return
	
	var response = target.add_item(item.item_name)
	if not response.succes:
		return
	
	if response.leftover > 0:
		item.item_quantity -= response.leftover
		return
	
	if item.global_position == target.global_position:
		item.queue_free()
		loading_item_into_target = false
	else:
		loading_item_into_target = true
		item.global_position = item.global_position.move_toward(target.global_position, blockData.speed / 2)
