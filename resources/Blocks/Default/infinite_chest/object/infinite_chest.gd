extends BaseLogisticsChest

func _ready() -> void:
	super._ready()
	MapDataManager.tick.connect(_tick)
	
	# Define o tempo de delay entre a geração dos itens
	blockData['gen_delay'] = 0
	blockData['gen_cooldown'] = 10  # Número de ticks entre cada geração (1 segundo se for 60 ticks por segundo)

func _tick():
	blockData['gen_delay'] += 1
	
	if blockData['gen_delay'] >= blockData['gen_cooldown']:
		generate()
		blockData['gen_delay'] = 0  # Reseta o delay após gerar o itevisibility_changed
	pass

func generate():
	if blockData.get("request_item") and blockData.request_item != "":
		if blockData['last_requested_item'] != blockData['request_item']:
			inventory.clear()
			save_inventory()
			
		if can_add_item(blockData.request_item):
			if add_item(blockData.request_item, 1).succes:
				close_inventory()
		
		_update_place_holder()
