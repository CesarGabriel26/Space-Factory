extends baseMachine

func _ready():
	_load()
	_setup()

func _process(delta):
	_update()
	_move_item_in(delta)
	_move_items_out()
	pass

func _tick():
	var all_recipes = JsonManager.read_from_json_file("res://resources/data/json/recipes.json")
	var current_recipes = all_recipes[data.recipes_page]
	
	# Iterar sobre as receitas do forno
	for recipe in current_recipes:
		var require = recipe.require
		var result = recipe.result
		#var escoria = recipe.escoria
		
		var slots_to_remove = []
		var has_all_items = true
		
		# Checar se todos os itens requeridos estão no inventário
		for required_item in require:
			var item_name = required_item[0]
			var required_quantity = required_item[1]
			var item = InventoryManager.get_item_data_by_item_name(data.input_inv, item_name)
			
			if item:
				var available_quantity = item[1]
				var slot_id = InventoryManager.get_slot_by_item_name(data.input_inv, item_name)
				
				if available_quantity >= required_quantity:
					slots_to_remove.append([slot_id, required_quantity])
				else:
					has_all_items = false
					break
			else:
				has_all_items = false
				break
		
		# Processar a receita se todos os itens estiverem disponíveis
		if has_all_items:
			# Remover itens do inventário
			for slot in slots_to_remove:
				InventoryManager.get_and_remove_item_from_slot(data.input_inv, slot[0], slot[1])
			
			# Adicionar o item de resultado no inventário de saída
			for result_item in result:
				var result_name = result_item[0]
				var result_quantity = result_item[1]
				
				if InventoryManager.has_space_for_item(data.output_inv, result_name, result_quantity, 5):
					InventoryManager.add_item_to_inventory(data.output_inv, result_name, result_quantity, 1, 5)
			
			# Adicionar escória se aplicável
			#if escoria > 0:
				#InventoryManager.add_item_to_inventory(data.output_inv, "escoria", escoria, 1, 5)
			
			# Atualizar dados do mapa ou outro estado, se necessário
			MapDataManager.WorldTiles[data.map_pos] = data
			update_inv()
	
