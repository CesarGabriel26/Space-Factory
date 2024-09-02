extends BaseMachine
class_name CrafterMachine

# Determina se as partículas devem ser emitidas
func _should_emit_particles(results: Dictionary) -> bool:
	if results.has("result"):
		var result_item = results["result"]
		
		if results.has("escoria"):
			return check_out_slot_is_full(0, result_item[0][0]) and check_out_slot_is_full(1, "escoria")
		else:
			return check_out_slot_is_full(0, result_item[0][0])
	else:
		return false

func processar_minerio(minerios: Array) -> Dictionary:
	for recipe in MainGlobal.recipes[Machine]:
		var required_items = recipe["require"]
		if _has_required_items(minerios, required_items) and _can_continue_craft(inventory, required_items, recipe["result"]):
			# Remover os itens necessários do inventário
			_remove_items_from_inventory( required_items)
			
			# Processar o resultado
			var resultado = {
				"result": recipe["result"],
				"escoria": []
			}
			
			# Calcular chance de gerar escória
			if recipe.has("escoria") and randf() < recipe["escoria"]:
				resultado["escoria"].append("escoria")
			
			return resultado
	return {"erro": "Minerio não encontrado na receita", "data": minerios}

func _has_required_items(minerios: Array, required_items: Array) -> bool:
	for item in required_items:
		var item_name = item[0]
		var item_quantity_needed = item[1]
		
		if not minerios.has(item_name):
			return false
		if minerios[1] < item_quantity_needed:
			return false
	return true

func _can_continue_craft(inv: Dictionary, required_items: Array, result: Array):
	for id in Outinventory:
		if Outinventory[id][0] == result[0][0]:
			if Outinventory[id][1] + result[id][1] > MaxStack:
				return false
	
	return true

func _remove_items_from_inventory(required_items: Array) -> void:
	for item in required_items:
		var slotIndex = get_slot_by_item(item[0], inventory)
		get_and_remove_item_from_slot(slotIndex, item[1], inventory)

func get_items_for_crafting(inventory: Dictionary) -> Array:
	var items = []
	for slot in inventory.keys():
		items.append_array(inventory[slot])
	return items

