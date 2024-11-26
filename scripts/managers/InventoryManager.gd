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

func add_item_to_inventory(inv : Dictionary, item_name : String, item_quantity : int):
	var slot_indices: Array = inv.keys()
	slot_indices.sort()
	
	for item in slot_indices:
		if inv[item][0] == item_name:
			var able_to_add = MaxStack - inv[item][1]
			if able_to_add >= item_quantity:
				inv[item][1] += item_quantity
				return inv
			else:
				inv[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NumSlots):
		if inv.has(i) == false:
			inv[i] = [item_name, item_quantity]
			return inv
		else:
			if inv[i][0] == item_name:
				return inv

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

func has_space_for_item(inv: Dictionary, item_name: String, quantity: int) -> bool:
	var total_space = 0
	for slot in inv:
		if inv[slot][0] == item_name:
			total_space += MaxStack - inv[slot][1]
		elif !inv.has(slot): # Slot vazio
			total_space += MaxStack
	
	return total_space >= quantity

func get_and_remove_item_from_last_slot(inv : Dictionary):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		inv[idx][1] -= 1
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

func get_item_from_last_slot(inv : Dictionary):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		return item_to_return
	else:
		return null

func get_item_data_from_slot(inv : Dictionary, slotIndex : int):
	if inv.size() > 0 and inv.has(slotIndex):
		var item_to_return = inv[slotIndex][0]
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
