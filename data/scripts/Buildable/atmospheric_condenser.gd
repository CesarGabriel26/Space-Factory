extends baseMachine

func _ready():
	_load()
	_setup()

func _process(delta):
	_update()
	_animate()
	_move_fluids_out()
	
	
	var fill_sprite = $Colors/Fluid
	var fluid = InventoryManager.get_item_from_last_slot(data.fluid_output_inv, true)
	
	fill_sprite.visible = (fluid != null)
	
	if fluid:
		var target_alpha = fluid[1] / 1200.0
		var current_alpha = fill_sprite.modulate.a
		var new_alpha = lerp(current_alpha, target_alpha, 0.1)  # 0.1 controla a suavidade
		fill_sprite.modulate = Color(0, 0, 1, new_alpha)
	
	pass

func _tick():
	var all_recipes = JsonManager.read_from_json_file("res://resources/data/json/recipes.json")
	var current_recipes = all_recipes["fluid_condenser"]
	
	var tile_data = MapDataManager.WorldData[data.map_pos.x][data.map_pos.y]
	var environment_data = {
		"ambiente_humidity": tile_data.humidity
	}  # Dados do ambiente
	var require = current_recipes[0].require
	
	if ConditionManager.check_conditions(require, environment_data):
		
		var humidity = environment_data["ambiente_humidity"]
		
		var water_generated = 600
		
		InventoryManager.add_item_to_inventory(data.fluid_output_inv, "Water", water_generated, 1, 
			JsonManager.get_on_json_by_keys(
				"res://resources/data/json/fluids.json", 
				[
					"Water",
					"stack"
				]
			)
		)
		
		MapDataManager.WorldTiles[data.map_pos] = data
	else:
		print("Condições não atendidas.")  # Debug
		print(environment_data)
