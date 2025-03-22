extends BaseInventoryBlock
class_name Drill

func _ready() -> void:
	if blockData.get("is_preview"): return
	MapDataManager.tick.connect(_tick)
	
	# Define o tempo de delay entre a geração dos itens
	blockData['gen_delay'] = 0
	blockData['gen_cooldown'] = 60  # Número de ticks entre cada geração (1 segundo se for 60 ticks por segundo)

func _tick():
	blockData['gen_delay'] += 1
	if blockData['gen_delay'] >= blockData['gen_cooldown']:
		generate()
		blockData['gen_delay'] = 0  # Reseta o delay após gerar o itevisibility_changed
	
	if internalItemUnloadersNode.get_child_count() > 0:
		for internalItemUnloader : InternalItemUnloader in internalItemUnloadersNode.get_children():
			internalItemUnloader._tick()

var check_index = 0
func get_ore():
	var positions : Array = blockData.positions_on_map.duplicate()
	positions.push_front(Vector2.ZERO)
	
	var resource_atlas = MapDataManager.get_resource_at(blockData.map_pos + positions[check_index])
	var resource_name = null
	
	if resource_atlas != Vector2(-1, -1):
		resource_name = Consts.RESOURCES_ATLAS_TO_NAME[resource_atlas]
	
	if check_index < 3:
		check_index += 1
	else:
		check_index = 0
	
	return resource_name

func generate():
	var ore = get_ore()
	if not ore:
		return
	
	if can_add_item(ore):
		add_item(ore, 1)
		close_inventory()
