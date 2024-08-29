extends BaseMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	recipes = [
		{
			"require": ["minerio_de_cobre"],
			"result": ["barra_de_cobre"],
			"escoria": 0.1
		},
		{
			"require": ["minerio_de_ferro"],
			"result": ["barra_de_ferro"],
			"escoria": 0.15
		},
		{
			"require": ["minerio_de_ouro"],
			"result": ["barra_de_ouro"],
			"escoria": 0.05
		},
		{
			"require": ["minerio_de_zinco"],  # Exemplo com múltiplos itens
			"result": ["barra_de_zinco"],
			"escoria": 0.2
		}
	]
	
	_setup()
	pass # Replace with function body.

func _process(delta):
	update_tick()
	pass

func tick():
	if inventory.has(0) and (check_out_slot_is_full(0) and check_out_slot_is_full(1)):
		var results = processar_minerio(get_items_for_crafting(inventory))
		
		if results.has("result"):
			for idx in range(results["result"].size()):
				var result_item = results["result"][idx]
				if check_out_slot_is_full(idx, result_item):
					add_item_to_especific_slot(idx, result_item, 1)
					get_and_remove_item_from_last_slot(inventory)
		
		if (results.has("escoria") and results["escoria"].size() > 0) and check_out_slot_is_full(1, "escoria"):
			add_item_to_especific_slot(1, "escoria", 1)
		
		check_and_load_outinv_ui()
		
		$CPUParticles2D.emitting = _should_emit_particles(results)
	else:
		$CPUParticles2D.emitting = false
	
	active = $CPUParticles2D.emitting

# Determina se as partículas devem ser emitidas
func _should_emit_particles(results: Dictionary) -> bool:
	if results.has("escoria"):
		return check_out_slot_is_full(0, results["result"][0]) and check_out_slot_is_full(1, "escoria")
	else:
		return check_out_slot_is_full(0, results["result"][0])

func processar_minerio(minerios: Array) -> Dictionary:
	for recipe in recipes:
		var required_items = recipe["require"]
		if _has_required_items(minerios, required_items):
			# Remover os itens necessários do inventário
			_remove_items_from_inventory(inventory, required_items)
			
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

# Verificar se todos os itens necessários estão disponíveis
func _has_required_items(minerios: Array, required_items: Array) -> bool:
	for item in required_items:
		if not minerios.has(item):
			return false
	return true

# Remover os itens necessários do inventário
func _remove_items_from_inventory(inventory: Dictionary, required_items: Array) -> void:
	for item in required_items:
		# Supondo que 'get_and_remove_item_from_last_slot' remova um item do inventário
		get_and_remove_item_from_last_slot(inventory)

func get_items_for_crafting(inventory: Dictionary) -> Array:
	var items = []
	for slot in inventory.keys():
		items.append(inventory[slot][0])
	return items
