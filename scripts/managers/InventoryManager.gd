extends Node

const MaxStack = 5
const NumSlots = 4

func move_item_between_inventories(source_inv: Dictionary, target_inv: Dictionary, slot_index: int, quantity: int):
	if source_inv.has(slot_index):
		var item_data = source_inv[slot_index]
		var item_name = item_data[0]
		var item_quantity = min(item_data[1], quantity)
		
		# Tentar adicionar ao inventário de destino
		add_item_to_inventory(target_inv, item_name, item_quantity)
		
		# Remover do inventário de origem
		get_and_remove_item_from_slot(source_inv, slot_index, item_quantity)

func clear_inventory(inv: Dictionary):
	inv.clear()

func add_item_to_inventory(inv : Dictionary, item_name : String, item_quantity : int = 1, num_slots : int = NumSlots, max_stack = MaxStack):
	var slot_indices: Array = inv.keys()
	slot_indices.sort()
	
	if item_quantity <= 0:
		return false
	
	for item in slot_indices:
		if inv[item][0] == item_name:
			var able_to_add = max_stack - inv[item][1]
			if able_to_add >= item_quantity:
				inv[item][1] += item_quantity
				return true
			else:
				inv[item][1] += able_to_add
				return false
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	
	for i in range(num_slots):
		if inv.has(i) == false:
			inv[i] = [item_name, item_quantity]
			return true
		else:
			if inv[i][0] == item_name:
				return true
	
	return false

func add_item_to_especific_slot( inv : Dictionary, slotIndex : int, item_name : String, item_quantity : int):
	if inv.has(slotIndex) == false:
		inv[slotIndex] = [item_name, item_quantity]
	else:
		if inv[slotIndex][0] == item_name:
			var able_to_add = MaxStack - inv[slotIndex][1]
			if able_to_add >= item_quantity:
				inv[slotIndex][1] += item_quantity
				return
			else:
				inv[slotIndex][1] += able_to_add
				item_quantity = item_quantity - able_to_add

func check_item_quantity(inv : Dictionary, slotIndex : int):
	if inv[slotIndex][1] <= 0:
		inv.erase(slotIndex)

func check_slot_is_full(inv : Dictionary, slot_index : int):
	if !inv.has(slot_index):
		return false
	elif inv.has(slot_index) and (inv[slot_index][1] + 1) <= MaxStack:
		return false
	elif inv.has(slot_index) and (inv[slot_index][1] + 1) > MaxStack:
		return true
	else:
		return false

func has_space_for_item(inv: Dictionary, item_name: String, item_quantity: int, num_slots : int = NumSlots, stack_size : int = MaxStack):
	var slot_indices: Array = inv.keys()
	slot_indices.sort()
	
	if inv.is_empty():
		return item_quantity
	
	for item in slot_indices:
		
		if inv.has(item) == false:
			return item_quantity
		
		if inv[item][0] == item_name:
			var able_to_add = stack_size - inv[item][1]
			if able_to_add >= item_quantity:
				return item_quantity
			else:
				return able_to_add

func get_and_remove_item_from_last_slot(inv : Dictionary ,Quantity : int = 1):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		inv[idx][1] -= Quantity
		check_item_quantity(inv, idx)
		return item_to_return
	
	return null

func get_and_remove_item_from_slot(inv : Dictionary, slotIndex : int = 0 ,Quantity : int = 1):
	if inv.size() > 0:
		var item_to_return = inv[slotIndex][0]
		inv[slotIndex][1] -= Quantity
		check_item_quantity(inv, slotIndex)
		return item_to_return
	else:
		return null

func get_item_from_last_slot(inv : Dictionary, with_quantity: bool = false):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		
		if with_quantity:
			return inv[idx]
		
		return item_to_return
	else:
		return null

func get_item_data_from_slot(inv : Dictionary, slotIndex : int, with_quantity: bool = false):
	if inv.size() > 0 and inv.has(slotIndex):
		var item_to_return = inv[slotIndex][0]
		
		if with_quantity:
			return inv[slotIndex]
		
		return item_to_return
	else:
		return null

func get_item_data_by_item_name(inv : Dictionary,item_name: String):
	for i in inv:
		if inv[i][0] == item_name :
			return inv[i]
	return null

func get_slot_by_item_name(inv : Dictionary, item_name: String):
	for index in inv:
		if inv[index][0] == item_name:
			return index
	return null
