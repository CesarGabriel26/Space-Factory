extends Node

var expectingItem = false
var ItemOutputsNode : Node2D = null

#func handle_especific_output(rayname):
	#if Type in [types.Process, types.Filter]:
		#var expected_item_slot_id = 0
		#
		#if ExpectedItemsOutput.has(rayname):
			#var expected_output = ExpectedItemsOutput[rayname]
			#
			#match typeof(expected_output):
				#TYPE_INT:
					#expected_item_slot_id = expected_output
				#TYPE_STRING:
					#expected_item_slot_id = get_slot_by_item(expected_output)
		#
			#return expected_item_slot_id

func move_item_out():
	if expectingItem:
		return
	
	var marcadores = ItemOutputsNode.get_children()
	
	for marcador : Marker2D in marcadores:
		var rays = marcador.get_children()
		
		for ray : RayCast2D in rays:
			var colider = ray.get_collider()
			var real_out_direction = out_direction
			
			if !MonoOutput:
				if ray.target_position.x != 0:
					real_out_direction.x = ray.target_position.x / ray.target_position.x
					if ray.target_position.x < 0:
							real_out_direction.x *= -1
							
				if ray.target_position.y != 0:
					real_out_direction.y = ray.target_position.y / ray.target_position.y
					if ray.target_position.y < 0:
						real_out_direction.y *= -1
			
			if colider and colider.out_direction + real_out_direction != Vector2.ZERO:
				# Verificando se o RayCast está mapeado para um item específico
				var rayname = int(str(ray.name))
				var item_to_move = null
				var expected_item_slot = handle_especific_output(rayname)
				
				if expected_item_slot != null:
					if typeof(expected_item_slot) == TYPE_STRING and expected_item_slot == "notFound": continue 
					item_to_move = get_item_from_slot(expected_item_slot)
				else:
					item_to_move = get_item_from_last_slot()
				
				# Se encontrou um item para mover
				if item_to_move != null and colider.can_recive_item(item_to_move):
					colider.expectingItem = true
					# Removendo o item do inventário
					if expected_item_slot != null:
						item_to_move = get_and_remove_item_from_slot(expected_item_slot)
					else:
						item_to_move = get_and_remove_item_from_last_slot()  # Ou outra função para remover o item qualquer
						
					var item : ItemBox = item_box.instantiate()
					item._load_item(item_to_move)
					
					MainGlobal.Items_Noode.add_child(item)
					
					item.global_position = marcador.global_position
					colider.InputSlot = item
				#else:
				#	print("RayCast2D '{}' não encontrou um item para mover.".format(ray.name))
	
	check_and_load_outinv_ui()

func move_item_in():
	if !ItemInputsNode:
		return
	
	if InputSlot != null and expectingItem == true:
		var maisProximo = null
		var menorDistancia = INF  # Começamos com a maior distância possível.
		for input in ItemInputsNode.get_children():
			var distanciaAtual = InputSlot.global_position.distance_to(input.global_position)
			
			if distanciaAtual < menorDistancia:
				menorDistancia = distanciaAtual
				maisProximo = input
			
		if maisProximo != null:
			var dir = InputSlot.global_position.direction_to(maisProximo.global_position)
			var distance = InputSlot.global_position.distance_to(maisProximo.global_position)
			
			if distance > 0.5:
				var vel = MainGlobal.conveyor_speed[0]
				
				if typeof(data["tier"]) != TYPE_STRING:
					vel = MainGlobal.conveyor_speed[data["tier"]]
				
				InputSlot.global_position += (dir * vel)
			else:
				if Type == types.Process:
					add_item_to_inventory(InputSlot.item_name, 1, inventory)
				else:
					add_item_to_inventory(InputSlot.item_name, 1)
				
				InputSlot.queue_free()
				InputSlot = null
				expectingItem = false
	
	check_and_load_inv_ui()

func can_recive_item(item_name):
	if expectingItem or (ItemInputsNode == null and ItemOutputsNode == null) or Type == types.Starter:
		return false
	
	var can_receive = true
	
	if Type == types.Process:
		for key in inventory:
			if inventory[key][0] == item_name:
				if (inventory[key][1] + 1) > MaxStack:
					can_receive = false
				else:
					can_receive = true
					break
					
				
			elif inventory.size() > 0:
				if (inventory.size() + 1) > NumSlots:
					can_receive = false
				else:
					can_receive = true
					break
	else:
		for key in Outinventory:
			if Outinventory[key][0] == item_name:
				if (Outinventory[key][1] + 1) > MaxStack:
					can_receive = false
				else:
					can_receive = true
					break
					
				
			elif Outinventory.size() > 0:
				if (Outinventory.size() + 1) > NumSlots:
					can_receive = false
				else:
					can_receive = true
					break
	
	if Type == types.Process:
		for recipe in MainGlobal.recipes[Machine]:
			if item_name in recipe['require']:
				can_receive = true
				break 
	
	return can_receive
