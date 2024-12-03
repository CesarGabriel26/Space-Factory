extends baseMachine

func _ready():
	_load()
	_setup()

func _process(delta):
	_update()

func _tick():
	randomize()
		
	var random_value = randf()
	var cumulative_probability = 0.0
	
	var pos = data.map_pos
	var items_to_generate = data.items_to_generate
	var res = ""
	
	for resource in items_to_generate:
		cumulative_probability += items_to_generate[resource]
		if random_value <= cumulative_probability:
			res = resource
			break
	
	InventoryManager.add_item_to_inventory(data.output_inv, res, 1)
	MapDataManager.WorldTiles[pos].output_inv = data.output_inv
	$InvPreview/invController._update(pos)
