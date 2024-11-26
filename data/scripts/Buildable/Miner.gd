extends baseBlock

var time = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	_load()
	print(data.map_pos)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if time <= 0:
		time = 50
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
		
		var out_inv = InventoryManager.add_item_to_inventory(data.output_inv, res, 1)
		#GlobalData.WorldTiles[pos].output_inv = out_inv
		data.output_inv = out_inv
		
		$InvPreview/invController._update(data.map_pos)
	else:
		time -= 1
	
	pass
