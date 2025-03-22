extends BaseBlock
class_name BaseItemTransferBlock

@export var ItemPosition : Node2D = null

#Tier	Itens/s (1 item por vez)	Velocidade (1 iten simultâneo)
#1		7.5							4
#2		15							8
#3		22.5						12
#4		30							16


func can_receive_item():
	return ItemPosition.get_child_count() == 0

func receive_item(item: Node2D):
	item.reparent(ItemPosition, true)
	blockData.moving_item = true

func offload_item():
	var item = ItemPosition.get_child(0)
	return item

func hold_item():
	blockData.moving_item = false

func _physics_process(delta: float) -> void:
	if not blockData.moving_item or ItemPosition.get_child_count() == 0 or blockData.get('is_preview', false):
		return
	
	var item = ItemPosition.get_child(0)
	var speed = blockData.speed
	
	if typeof(speed) == TYPE_ARRAY:
		speed = speed[blockData.tier]
	
	if item is Node2D:
		item.global_position = item.global_position.move_toward(
			ItemPosition.global_position,
			speed
		)
		
		if item.global_position == ItemPosition.global_position:
			hold_item()

func move_item_to_target(_input_target : BaseBlock = null):
	if blockData.moving_item or ItemPosition.get_child_count() == 0:
		return
	var target = _input_target
	
	if not target:
		target = MapDataManager.get_prop_at(
			blockData.map_pos + blockData.pointing_to
		)
	if not target:
		return
	
	
	if not _input_target and not target is Conveyor:
		return
	
	if not target.can_receive_item():
		return
	
	var item = offload_item()
	target.receive_item(item)
