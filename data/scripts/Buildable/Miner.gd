extends baseMachine


var index = 0
var items_to_gen = {
	Vector2(1, 1) : "minerio_de_cobre",
	Vector2(0, 1) : "minerio_de_ferro",
	Vector2(0, 2) : "minerio_de_ouro",
	Vector2(1, 2) : "minerio_de_zinco"
}

func _ready():
	_load()
	_setup()

func _process(delta):
	_update()
	_move_items_out()
	pass

func _tick():
	var tile_data = world_ref.visible_map.get_cell_atlas_coords(data.occupiedTiles[index])
	
	if items_to_gen.has(Vector2(tile_data)):
		var res = items_to_gen[Vector2(tile_data)]
		
		InventoryManager.add_item_to_inventory(data.output_inv, res, 1)
		MapDataManager.WorldTiles[data.map_pos].output_inv = data.output_inv
		update_inv()
	
	index += 1
	if index >= data.occupiedTiles.size():
		index = 0
