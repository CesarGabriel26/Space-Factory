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

func _move_item_to_block(block_occupied_tiles: Array, item_name : String, cicle : bool = false):
	if cicle:
		_move_to_blocks_cycling(block_occupied_tiles, item_name)
	else:
		_move_to_nearest_block(block_occupied_tiles, item_name)
	pass

func _move_to_nearest_block(block_occupied_tiles: Array, item_name : String):
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
			if !target_data.has('output_inv') and !target_data.has('input_inv'):
				return false
			
			if target_data.waiting_for_item:
				return false
			
			var target_input_inv = {}
			
			if target_data.has('input_inv'):
				target_input_inv = target_data.input_inv
			elif target_data.has('output_inv'):
				target_input_inv = target_data.output_inv
			
			var block_output_inv = block_data.output_inv
			
			var slot_id = InventoryManager.get_slot_by_item_name(block_output_inv, item_name)
			
			if slot_id != null:
				_mote_item(
					target_data, 
					target_input_inv, 
					block_output_inv, 
					item_name, 
					pos, 
					slot_id
				)
			else:
				break

func _move_to_blocks_cycling(block_occupied_tiles: Array, item_name: String):
	var positions_to_try = []
	var block_data = {}
	var last_out_index = 0
	
	for pos in block_occupied_tiles:
		var pos_out_dir = MapDataManager.WorldTiles[pos].out_dir
		block_data = _get_block_data(pos)
		
		if block_data.has('last_out_index'):
			last_out_index = block_data['last_out_index']
		
		if typeof(pos_out_dir) == TYPE_ARRAY:
			var targets : Array = _has_block_to_interact(pos, pos_out_dir)
			for target in targets:
				positions_to_try.append(target)
		else:
			var targets : Array = _has_block_to_interact(pos, pos_out_dir)
			positions_to_try.append(targets)
	
	if positions_to_try.size() < 1:
		return false
	
	var pos = positions_to_try[last_out_index]
	var target_data = _get_block_data(pos)
	
	if target_data.has('building'):
		return false
	
	if target_data.waiting_for_item:
		return false
	
	var target_input_inv = {}
	
	if target_data.has('input_inv'):
		target_input_inv = target_data.input_inv
	else:
		target_input_inv = target_data.output_inv
	
	var block_output_inv = block_data.output_inv
	
	var slot_id = InventoryManager.get_slot_by_item_name(block_output_inv, item_name)
	if slot_id != null:
		var res = _mote_item(
			target_data, 
			target_input_inv, 
			block_output_inv, 
			item_name, 
			pos, 
			slot_id
		)
		
		last_out_index = (last_out_index + 1) % positions_to_try.size()
		
		if last_out_index == positions_to_try.size():
			last_out_index = 0
		
		block_data['last_out_index'] = last_out_index
		MapDataManager.WorldTiles[block_data.map_pos] = block_data
		
		return res
	else:
		return false

func _mote_item(target_data : Dictionary, target_input_inv : Dictionary, block_output_inv : Dictionary, item_name: String, pos: Vector2, slot_id : int):
	var max_stack = InventoryManager.MaxStack
	
	if target_data.has('max_stack'):
		max_stack = target_data.max_stack
	else:
		var stack = JsonManager.search_for_item(item_name).stack
		if stack != "default" or stack == null:
			max_stack = stack
	
	
	var can_add = InventoryManager.has_space_for_item(
		target_input_inv, 
		item_name, 
		1,
		target_data.inventory.item_inventory_size,
		max_stack,
	)
	
	if can_add:
		var item_to_transfer = InventoryManager.get_and_remove_item_from_slot(block_output_inv, slot_id)
		var item = ITEM_BOX.instantiate()
		
		target_data.waiting_for_item = item
		item.item_name = item_name
		get_tree().root.get_node('mainWorld/Items').add_child(item)
		
		item.global_position = (pos * 32) + Vector2(16,16)
		return true
	else:
		return false

func _move_item_to_target(data, delta):
	if data.waiting_for_item:
		var node : Node2D = data.waiting_for_item
		var my_pos : Vector2 = (data.map_pos * 32)
		
		for tile in data.occupiedTiles:
			var world_pos = (tile * 32)
			
			if node.global_position.distance_to(world_pos) < node.global_position.distance_to(my_pos):
				my_pos = world_pos
		
		my_pos = my_pos + Vector2(16,16)
		
		var dir = node.global_position.direction_to(my_pos)
		var distance = node.global_position.distance_to(my_pos)
		
		if distance > 0.5:
			var vel = 1
			node.global_position += (dir * vel)
		else:
			var my_input_inv = {}
			
			if data.has('input_inv'):
				my_input_inv = data.input_inv
			else:
				my_input_inv = data.output_inv
			
			var max_stack = 5
			if data.has('max_stack'):
				max_stack = data.max_stack
			else:
				var stack = JsonManager.search_for_item(node.item_name).stack
				if stack != "default" or stack == null:
					max_stack = stack
			
			if InventoryManager.add_item_to_inventory(my_input_inv, node.item_name, 1, data.inventory.item_inventory_size, max_stack):
				node.queue_free()
				data.waiting_for_item = false
				
				if data.has('input_inv'):
					data.input_inv = my_input_inv
				else:
					data.output_inv = my_input_inv
				
				MapDataManager.WorldTiles[data.map_pos] = data
