extends Node

const ITEM_BOX = preload("res://data/Entities/props/item_box.tscn")

func _has_block_to_interact(map_pos: Vector2 = Vector2.ZERO, out_dirs : Array = []):
	var targets = []
	
	for out_dir in out_dirs:
		var target = map_pos + out_dir
		if MapDataManager.WorldTiles.has(target):
			var t = MapDataManager.WorldTiles[target]
			
			if typeof(t.out_dir) == TYPE_ARRAY:
				for p in t.out_dir:
					if p + out_dir != Vector2.ZERO:
						targets.append(target)
			else:
				if t.out_dir + out_dir != Vector2.ZERO:
					targets.append(target)
			
	
	return targets

func _get_block_data(pos : Vector2):
	var block = MapDataManager.WorldTiles[pos]
	
	if block.has('ref'):
		block = MapDataManager.WorldTiles[block.ref]
	
	return block

func _move_fluid_to_block(block_occupied_tiles: Array, fluid_name : String, cicle : bool = false):
	if cicle:
		pass
	else:
		_move_to_nearest_block(block_occupied_tiles, fluid_name)
	pass

func _move_to_nearest_block(block_occupied_tiles: Array, fluid_name : String):
	for pos in block_occupied_tiles:
		var pos_out_dir = MapDataManager.WorldTiles[pos].out_dir
		var block_data = _get_block_data(pos)
		
		if typeof(pos_out_dir) != TYPE_ARRAY:
			pos_out_dir = [pos_out_dir]
		
		var targets : Array = _has_block_to_interact(pos, pos_out_dir)
		
		for target in targets:
			var target_data = _get_block_data(target)
			
			if target_data.has('building'):
				return false
			if !target_data.has('fluid_output_inv') and !target_data.has('fluid_input_inv'):
				return false
			
			if target_data.waiting_for_fluid:
				return false
			
			var target_input_inv = {}
			
			if target_data.has('fluid_input_inv'):
				target_input_inv = target_data.fluid_input_inv
			elif target_data.has('fluid_output_inv'):
				target_input_inv = target_data.fluid_output_inv
			
			var block_output_inv = block_data.fluid_output_inv
			
			var slot_id = InventoryManager.get_slot_by_item_name(block_output_inv, fluid_name)
			
			if slot_id != null:
				_move_fluid(
					target_data, 
					target_input_inv, 
					block_output_inv, 
					fluid_name, 
					pos, 
					slot_id
				)
				MapDataManager.WorldTiles[block_data.map_pos] = block_data
			else:
				break

func _move_fluid(target_data : Dictionary, target_input_inv : Dictionary, block_output_inv : Dictionary, item_name: String, pos: Vector2, slot_id : int):
	var max_stack = InventoryManager.MaxStack
	
	if target_data.has('max_stack'):
		max_stack = target_data.max_stack
	else:
		var stack = JsonManager.search_for_item(item_name).stack
		if (typeof(stack) == TYPE_STRING and stack != "default") or stack != null:
			max_stack = stack
	
	var item_to_check = InventoryManager.get_item_data_from_slot(block_output_inv, slot_id, true)
	var can_add = InventoryManager.has_space_for_item(
		target_input_inv, 
		item_name, 
		remove_half(item_to_check[1]),
		target_data.inventory.item_inventory_size,
		max_stack,
	)
	
	if bool(can_add):
		InventoryManager.add_item_to_inventory(
			target_data.fluid_input_inv,
			item_name,
			can_add,
			1,
			max_stack,
		)
		
		InventoryManager.get_and_remove_item_from_slot(block_output_inv, slot_id, can_add)
		return true
	else:
		return false

func remove_half(value: int) -> int:
	if value == 1 or value == 0:
		return value  # Não modifica se for 1 ou 0
	else:
		var half = ceil(value / 2.0)  # Calcula a metade, arredondando para cima
		return value - half  # Subtrai a metade do valor original
