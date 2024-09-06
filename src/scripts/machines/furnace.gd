extends CrafterMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	outInventory_node = $inventory/inv_grid2
	BuildingModeInAndOutPreview = $"model/Inputs-outputs"
	_setup()
	pass # Replace with function body.

func _process(delta):
	update_tick()
	pass

func tick():
	if !active:
		return
	
	if inventory.has(0) and check_out_slot_is_full(0) and check_out_slot_is_full(1):
		var results = processar_minerio(get_items_for_crafting(inventory))
		if results.has("result"):
			for idx in range(results["result"].size()):
				var result_item = results["result"][idx]
				if check_out_slot_is_full(idx, result_item[0]):
					add_item_to_especific_slot(idx, result_item[0], result_item[1])
			
			if (results.has("escoria") and results["escoria"].size() > 0) and check_out_slot_is_full(1, "escoria"):
				add_item_to_especific_slot(1, "escoria", 1)
			
			check_and_load_outinv_ui()
		
		$CPUParticles2D.emitting = true
	else:
		$CPUParticles2D.emitting = false
	
