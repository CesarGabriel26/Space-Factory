extends StaticBody2D
class_name BaseMachine

signal ItemRecived

enum types {
	Starter = 0,
	Process,
	Reciver
}

@export_category("properties")
@export var Machine : String = ""
@export var Type : types = types.Reciver
@export var out_direction : Vector2 = Vector2.DOWN
@export var IsAutotile : bool = false
@export var MonoOutput : bool = false

@export_subgroup("nodes")
@export var colisionShape : CollisionShape2D = null
@export var tierColor : Polygon2D = null

@export_category("Inventory")
@export var NumSlots : int = 1
@export var MaxStack : int = 5
@export var InputSlot : ItemBox = null
@export var inventory_node : InventoryGrid = null
@export var outInventory_node : InventoryGrid = null

@export_category("inputs / outputs")
@export var MouseDetectionPanel : Panel = null
@export var ItemOutputsNode : Node2D = null
@export var ExpectedItemsOutput : Dictionary = {}
@export var ItemInputsNode : Node2D = null
@export var BuildingModeInAndOutPreview : Node2D = null

@onready var item_box = preload("res://src/scenes/machines/item_box.tscn")

# variaveis ocultas
var data = {
	"delay" : 5,
	"tier" : 0,
	"resources" : {
		"minerio_de_cobre" : 0.5,  # 50% de chance
		"minerio_de_ferro" : 0.2,  # 20% de chance
		"minerio_de_ouro"  : 0.15, # 15% de chance
		"minerio_de_zinco" : 0.15  # 15% de chance
	}
}
var recipes = []

var currentTime = 0
var expectingItem = false
var preview = false
var active = false

var inventory : Dictionary = {}
var Outinventory : Dictionary = {}

func _setup():
	if preview : return
	show_hide_inv(false)
	if MouseDetectionPanel:
		MouseDetectionPanel.connect("mouse_entered", show_hide_inv.bind(true))
		MouseDetectionPanel.connect("mouse_exited", show_hide_inv.bind(false))
	
	_reload()

func _reload():
	if MonoOutput:
		match out_direction:
			Vector2.DOWN:
				ItemOutputsNode.rotation_degrees = 0
			Vector2.LEFT:
				ItemOutputsNode.rotation_degrees = 90
			Vector2.UP:
				ItemOutputsNode.rotation_degrees = 180
			Vector2.RIGHT:
				ItemOutputsNode.rotation_degrees = -90
	
	if tierColor:
		tierColor.color = MainGlobal.machines_tier_color[float(data['tier'])]

func set_as_preview():
	colisionShape.disabled = true
	preview = true
	
	var marcadores = ItemOutputsNode.get_children()
	for marcador : Marker2D in marcadores:
		var rays = marcador.get_children()
		for ray : RayCast2D in rays:
			ray.enabled = false

func show_hide_inv(show : bool):
	if inventory_node:
		inventory_node.visible = show
	if outInventory_node:
		outInventory_node.visible = show

func update_tick():
	if preview : return
	update()
	if currentTime >= (data["delay"] * 10):
		currentTime = 0
		call_deferred('tick')
	else:
		currentTime += 1
	#print(int(currentTime / 10))

func update():
	if preview : return
	
	if BuildingModeInAndOutPreview:
		BuildingModeInAndOutPreview.visible = MainGlobal.BuildingMode
	
	if ItemOutputsNode:
		move_item_out()
	if InputSlot:
		move_item_in()

func get_pollution_value():
	# Retorna o valor de poluição baseado no tier da fornalha
	if Type != types.Reciver:
		return MainGlobal.pollution_values[float(data['tier'])]
	else:
		return 0.0  # Se o tier não for válido, retorna 0

# INVENTARIO

func check_and_load_inv_ui():
	if inventory_node == null:
		return
	
	for i in range(NumSlots):
		if inventory.has(i):
			if inventory_node.has_slot(i):
				inventory_node.update_item(i,inventory[i][0], inventory[i][1])
			else:
				inventory_node.add_item(i, inventory[i][0], inventory[i][1])
		elif !inventory.has(i) and inventory_node.has_slot(i):
			inventory_node.remove_item(i)

func check_and_load_outinv_ui():
	if outInventory_node == null:
		return
	
	for i in Outinventory.size() + 1:
		if Outinventory.has(i):
			if outInventory_node.has_slot(i):
				outInventory_node.update_item(i,Outinventory[i][0], Outinventory[i][1])
			else:
				outInventory_node.add_item(i, Outinventory[i][0], Outinventory[i][1])
				
		elif !Outinventory.has(i) and outInventory_node.has_slot(i):
			outInventory_node.remove_item(i)

func add_item_to_inventory(item_name : String, item_quantity : int, inv : Dictionary = Outinventory):
	var slot_indices: Array = inv.keys()
	slot_indices.sort()
	for item in slot_indices:
		if inv[item][0] == item_name:
			var able_to_add = MaxStack - inv[item][1]
			if able_to_add >= item_quantity:
				inv[item][1] += item_quantity
				
				if inv == Outinventory:
					check_and_load_outinv_ui()
				else:
					check_and_load_inv_ui()
					
				return
			else:
				inv[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NumSlots):
		if inv.has(i) == false:
			inv[i] = [item_name, item_quantity]
			
			if inv == Outinventory:
				check_and_load_outinv_ui()
			else:
				check_and_load_inv_ui()
			
			return
		else:
			if inv[i][0] == item_name:
				return

func add_item_to_especific_slot(id : int, item_name : String, item_quantity : int, inv : Dictionary = Outinventory):
	if inv.has(id) == false:
		inv[id] = [item_name, item_quantity]
	else:
		if inv[id][0] == item_name:
			var able_to_add = MaxStack - inv[id][1]
			if able_to_add >= item_quantity:
				inv[id][1] += item_quantity
				return
			else:
				inv[id][1] += able_to_add
				item_quantity = item_quantity - able_to_add
		
	if inv == Outinventory:
		check_and_load_outinv_ui()
	else:
		check_and_load_inv_ui()

func check_item_quantity(index : int, inv : Dictionary = Outinventory):
	if inv[index][1] <= 0:
		inv.erase(index)

func check_out_slot_is_full(slot_index : int, item_name : String = ""):
	if item_name != "":
	
		if Outinventory.has(slot_index) and Outinventory[slot_index][0] == item_name and (Outinventory[slot_index][1] + 1) <= MaxStack:
			return true
		elif Outinventory.has(slot_index) and Outinventory[slot_index][0] == item_name and (Outinventory[slot_index][1] + 1) > MaxStack:
			return false
		elif !Outinventory.has(slot_index):
			return true
		else:
			return false
	
	else:
		if Outinventory.has(slot_index) and (Outinventory[slot_index][1] + 1) <= MaxStack:
			return true
		elif Outinventory.has(slot_index) and (Outinventory[slot_index][1] + 1) > MaxStack:
			return false
		elif !Outinventory.has(slot_index):
			return true
		else:
			return false

func get_and_remove_item_from_last_slot(inv : Dictionary = Outinventory):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		inv[idx][1] -= 1
		check_item_quantity(idx, inv)
		if inv == Outinventory:
			check_and_load_outinv_ui()
		else:
			check_and_load_inv_ui()
		return item_to_return
	
	return null

func get_and_remove_item_from_slot(slotIndex : int = 0, inv : Dictionary = Outinventory):
	if inv.size() > 0:
		var item_to_return = inv[slotIndex][0]
		inv[slotIndex][1] -= 1
		check_item_quantity(slotIndex)
		check_and_load_inv_ui()
		return item_to_return
	else:
		return null

func get_item_from_slot(id : int, inv : Dictionary = Outinventory):
	if inv.size() > 0 and inv.has(id):
		var item_to_return = inv[id][0]
		return item_to_return
	else:
		return null

func get_item_from_last_slot(inv : Dictionary = Outinventory):
	if inv.size() > 0:
		var idx = inv.size() - 1
		var item_to_return = inv[idx][0]
		return item_to_return
	else:
		return null

func get_item_from_first_slot(inv : Dictionary = Outinventory):
	if inv.size() > 0:
		var item_to_return = inv[0][0]
		return item_to_return
	else:
		return null

func get_item_from_inventory(item_name: String):
	for i in inventory:
		if inventory[i][0] == item_name :
			return item_name
	return null

func get_and_remove_item_from_inventory(item_name: String):
	for i in range(inventory.size()):
		if inventory[i][0] == item_name:
			var item_to_return = inventory[i][0]
			inventory[i][1] -= 1
			check_item_quantity(i)
			check_and_load_inv_ui()
			return item_to_return
	return null

# END INVENTARIO

func move_item_out():
	if expectingItem:
		return
	
	var marcadores = ItemOutputsNode.get_children()
	
	for marcador : Marker2D in marcadores:
		var rays = marcador.get_children()
		
		for ray : RayCast2D in rays:
			ray.enabled = true
			var colider = ray.get_collider()
			
			if colider and colider.out_direction + out_direction != Vector2.ZERO:
				# Verificando se o RayCast está mapeado para um item específico
				var expected_item_slot = null
				var item_to_move = null
				var rayname = int(str(ray.name))
				
				if Type == types.Process and ExpectedItemsOutput.has(rayname):
					expected_item_slot = ExpectedItemsOutput[rayname]
				
				if expected_item_slot != null:
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
				InputSlot.global_position += (dir * MainGlobal.conveyor_speed[data["tier"]])
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
	if expectingItem:
		return false
	
	for key in inventory:
		if inventory[key][0] == item_name:
			#print("Item existe")
			if (inventory[key][1] + 1) > MaxStack:
				return false
		elif inventory.size() > 0:
			if (inventory.size() + 1) > NumSlots:
				return false
	
	if Type == types.Process:
		for recipe in recipes:
			if item_name in recipe['require']:
				return true
	
	return true
