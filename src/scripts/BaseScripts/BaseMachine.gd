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

@export_category("Inventory")
@export var NumSlots : int = 1
@export var MaxStack : int = 5
@export var InputSlot : ItemBox = null
@export var inventory : Dictionary = {}
@export var inventory_node : InventoryGrid = null

@export_category("inputs / outputs")
@export var MouseDetectionPanel : Panel = null
@export var ItemOutputsNode : Node2D = null
@export var ItemInputsNode : Node2D = null

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
	check_and_load_inv_ui()
	
	if ItemOutputsNode:
		move_item_out()
	if InputSlot:
		move_item_in()

func check_and_load_inv_ui():
	if inventory_node == null:
		return
	
	for i in range(NumSlots):
		if inventory.has(i):
			
			if inventory_node.has_slot(i):
				inventory_node.update_item_quantity(i, inventory[i][1])
			else:
				inventory_node.add_item(i, inventory[i][0], inventory[i][1])
				
		elif inventory_node.has_slot(i):
			inventory_node.remove_item(i)

func add_item_to_inventory(item_name : String, item_quantity : int):
	var slot_indices: Array = inventory.keys()
	slot_indices.sort()
	for item in slot_indices:
		if inventory[item][0] == item_name:
			var able_to_add = MaxStack - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				check_and_load_inv_ui()
				return
			else:
				inventory[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NumSlots):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			check_and_load_inv_ui()
			return
		else:
			if inventory[i][0] == item_name:
				return

func add_item_to_especific_slot(id : int, item_name : String, item_quantity : int):
	if inventory.has(id) == false:
		inventory[id] = [item_name, item_quantity]
		check_and_load_inv_ui()
		return
	else:
		if inventory[id][0] == item_name:
			var able_to_add = MaxStack - inventory[id][1]
			if able_to_add >= item_quantity:
				inventory[id][1] += item_quantity
				check_and_load_inv_ui()
				return
			else:
				inventory[id][1] += able_to_add
				item_quantity = item_quantity - able_to_add

func check_item_quantity(index : int):
	if inventory[index][1] <= 0:
		inventory.erase(index)

func get_and_remove_item_from_last_slot():
	if inventory.size() > 0:
		var idx = inventory.size() - 1
		var item_to_return = inventory[idx][0]
		inventory[idx][1] -= 1
		check_item_quantity(idx)
		check_and_load_inv_ui()
		return item_to_return
	else:
		return null

func get_item_from_last_slot():
	if inventory.size() > 0:
		var idx = inventory.size() - 1
		var item_to_return = inventory[idx][0]
		return item_to_return
	else:
		return null

func get_item_from_first_slot():
	if inventory.size() > 0:
		var item_to_return = inventory[0][0]
		return item_to_return
	else:
		return null

func move_item_out():
	if expectingItem:
		return
	
	var marcadores = ItemOutputsNode.get_children()
	
	for marcador : Marker2D in marcadores:
		var rays = marcador.get_children()
		
		for ray : RayCast2D in rays:
			
			ray.enabled = true
			var colider = ray.get_collider()
			
			if colider:
				var item_to_move = get_item_from_last_slot()
				if item_to_move != null and colider.can_recive_item(item_to_move):
					colider.expectingItem = true
					
					item_to_move = get_and_remove_item_from_last_slot()
					
					var item : ItemBox = item_box.instantiate()
					item._load_item(item_to_move)
					
					MainGlobal.Items_Noode.add_child(item)
					
					item.global_position = marcador.global_position
					colider.InputSlot = item
	pass

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
				add_item_to_inventory(InputSlot.item_name, 1)
				InputSlot.queue_free()
				expectingItem = false

func can_recive_item(item_name):
	if expectingItem:
		return false
	
	for key in inventory:
		if inventory[key][0] == item_name:
			if (inventory[key][1] + 1) > MaxStack:
				return false
	
	for key in NumSlots:
		if inventory.has(key) and (inventory.size() + 1) > NumSlots:
			return false
	
	if Type == types.Process:
		for recipe in recipes:
			if item_name in recipe['require']:
				return true
	
	return true
	
