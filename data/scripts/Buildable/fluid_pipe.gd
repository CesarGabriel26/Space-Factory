extends baseBlock


# Called when the node enters the scene tree for the first time.
func _ready():
	_load()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	data.fluid_output_inv = data.fluid_input_inv
	MapDataManager.WorldTiles[data.map_pos] = data
	_move_fluids_out()
	data.fluid_input_inv = data.fluid_output_inv
	MapDataManager.WorldTiles[data.map_pos] = data
	
	var fill_sprite : Sprite2D = $Sprites.get_child(1)
	var fluid = InventoryManager.get_item_from_last_slot(data.fluid_input_inv, true)
	
	fill_sprite.visible = (fluid != null)
	
	if fluid:
		var a = (fluid[1] / 1200.0)
		fill_sprite.modulate = Color(0, 0, 1, a)
	
	pass
