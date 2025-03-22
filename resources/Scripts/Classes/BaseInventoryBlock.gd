extends BaseBlock
class_name BaseInventoryBlock

var inventory : Dictionary = {}

func open_inventory():
	inventory = blockData.inventory.duplicate(true)

func save_inventory():
	blockData.inventory = inventory.duplicate(true)

func close_inventory():
	inventory.clear()

func get_item_max_stack(item_name : String) -> int:
	return DataManager.ItensData[item_name].stack

func can_add_item(item_name : String)  -> bool:
	open_inventory()
	var inventory_size = inventory.keys().size()
	var has_item = false
	
	for i in inventory.keys():
		if inventory[i][0] == item_name:
			has_item = true
	
	close_inventory()
	return inventory_size < blockData.inv_config.slot_count or has_item

func inventory_is_empty() -> bool:
	if inventory.is_empty():
		# caso a variavel local de inventario esteja vasia carregar o inventario apartir dos dados do bloco
		open_inventory()
	
	# checar se mesmo apos o carregamento o inventario esta vasio
	var is_empty = inventory.is_empty()
	
	return is_empty

func add_item(item_name: String, item_quantity: int = 1) -> Dictionary:
	if inventory.is_empty():
		open_inventory()
	
	var stack_size = int(blockData.inv_config.get("overwrite_item_stack", get_item_max_stack(item_name)))
	var remaining_quantity = item_quantity  # Quantidade restante a ser adicionada
	
	# Adicionar primeiro aos slots existentes
	for i in inventory.keys():
		if inventory[i][0] == item_name:
			var able_to_add = stack_size - inventory[i][1]
			var to_add = min(remaining_quantity, able_to_add)  # Nunca adiciona mais que o permitido
			inventory[i][1] += to_add
			save_inventory()
			
			remaining_quantity -= to_add
			if remaining_quantity <= 0:
				return {'succes': true, 'leftover': 0}  # Finaliza se não houver mais itens para adicionar
		
	# Criar novos slots sem ultrapassar o stack_size
	for i in range(blockData.inv_config.slot_count):
		if not inventory.has(i):
			var to_add = min(remaining_quantity, stack_size)  # Garante que não passa do limite
			inventory[i] = [item_name, to_add]
			save_inventory()
			
			remaining_quantity -= to_add
			if remaining_quantity <= 0:
				return {'succes': true, 'leftover': 0}  # Finaliza se não houver mais itens para adicionar
	
	if remaining_quantity == item_quantity:
		return {'succes': false, 'leftover': 0} # Retorna false caso nenhum item tenha sido adicionado
	
	return {'succes': true, 'leftover': remaining_quantity}  # Retorna o restante se ainda restarem itens não adicionados

func remove_item(slot_index: int, amount_to_remove: int = 1) -> Array:
	if inventory.is_empty():
		open_inventory()
	
	if inventory.has(slot_index):
		var item_data = inventory[slot_index]
		
		if amount_to_remove > item_data[1]:
			# Caso a quantidade a ser removida seja maior que a do slot, remove tudo
			amount_to_remove = item_data[1]
			item_data[1] = 0
		else:
			#caso não, remover a quantidade pedida do slot
			item_data[1] -= amount_to_remove
		
		if item_data[1] < 1:
			inventory.erase(slot_index) # Remove o slot do inventário se estiver vazio
		else:
			inventory[slot_index] = item_data # Atualiza o slot com os dados corretos
		
		# salvar e fechar o slot
		save_inventory()
		close_inventory()
		
		return [item_data[0], amount_to_remove] # Retorna [nome_do_item, quantidade_removida]
	
	close_inventory()
	return [] # Retorna um array vazio se o slot não existir

func remove_item_from_last_slot() -> Array:
	return remove_item(inventory.size() - 1)
