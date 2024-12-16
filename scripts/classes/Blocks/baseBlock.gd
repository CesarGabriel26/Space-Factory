extends StaticBody2D
class_name baseBlock

const explosionEffect = preload("res://resources/effects/ExplosionEffect/ExplosionEffect.tscn")
const building_spot = preload("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")

@export_category("Nodes")
@export var Sprites : Node2D
@export var Colision : CollisionShape2D
@export var invController : InvController
@export_category("Stats")
@export var life: float = 0.0
@export var explosion_radius : float = 1.0

var data = {}
var world_ref = null
var a = false

var animations = []

func _load():
	life = data['life']
	_load_texture()

func _load_texture():
	var loaded_textures = TextureManager._get_texture(data.texture)
	
	var size = loaded_textures['size']
	var textures = loaded_textures.textures
	
	for c in Sprites.get_children():
		c.queue_free()
	
	var offset_x = max(0, (size.x - 32) / 2)
	var offset_y = max(0, (size.y - 32) / 2)
	
	Sprites.position = Vector2(offset_x, offset_y)
	if Colision:
		Colision.position = Vector2(offset_x, offset_y)
		Colision.shape.size = size
	
	
	TextureManager._add_sprites(textures, true, animations, Sprites)
	

func _animate():
	for anim in animations:
		var node = anim.node
		var prop = anim.propriedade
		var operacao = anim.operacao
		var valor = anim.valor
		
		var current_value = node.get(prop)
		var new_value
		
		match operacao:
			'add':
				new_value = (current_value + valor)
		
		node.set(prop, new_value)

func _update_texture_rect(pos):
	for Sprite in Sprites.get_children():
		var t : AtlasTexture = Sprite.texture
		if t:
			t.region.position = pos

func receiveDemage(d : float):
	life -= d
	
	if life <= 0:
		explode()
	pass

func regenLife(r):
	life += r
	pass

func explode():
	# Instancia a cena de explosão
	var explosion_instance = explosionEffect.instantiate()
	
	get_parent().add_child(explosion_instance)
	
	# Posiciona a explosão na mesma posição do bloco
	explosion_instance.position = global_position
	explosion_instance.damage_base = data['life'] 
	explosion_instance.explode()
	
	if !a:
		var building_spot_instance = building_spot.instantiate()
		building_spot_instance.data_to_transfer = data
		building_spot_instance.toBuild = data['prop_scene']
		get_parent().add_child(building_spot_instance)
		building_spot_instance.global_position = global_position
		a = true
	
	# Remove o bloco após a explosão
	queue_free()

func update_inv():
	if invController:
		invController._update(data.map_pos)

func _move_items_out(cycling : bool = false):
	var item = InventoryManager.get_item_from_last_slot(data.output_inv)
	
	if item and !MapDataManager.WorldTiles[data.map_pos].waiting_for_item:
		var updated = ItemMovimentManager._move_item_to_block(data.occupiedTiles, item, cycling)
		data.output_inv = MapDataManager.WorldTiles[data.map_pos].output_inv
		
		update_inv()

func _move_item_in(delta):
	if data.waiting_for_item:
		var target_input_inv = {}
		if data.has('input_inv'):
			target_input_inv = data.input_inv
		else:
			target_input_inv = data.output_inv
		
		var max_stack = 5
		if data.has('max_stack'):
			max_stack = data.max_stack
		
		var can_add = InventoryManager.has_space_for_item(
			target_input_inv, 
			data.waiting_for_item.item_name, 
			1,
			data.inventory.item_inventory_size,
			max_stack
		)
		
		if can_add:
			ItemMovimentManager._move_item_to_target(data, delta)
			update_inv()

func _move_fluids_out(cycling : bool = false):
	var fluid = InventoryManager.get_item_from_last_slot(data.fluid_output_inv)
	
	if fluid and !MapDataManager.WorldTiles[data.map_pos].waiting_for_fluid:
		var updated = FluidMovimentManager._move_fluid_to_block(data.occupiedTiles, fluid, cycling)
		data.fluid_output_inv = MapDataManager.WorldTiles[data.map_pos].fluid_output_inv
	
	await get_tree().physics_frame

func _move_fluids_in(delta):
	if data.waiting_for_fluid and data.waiting_for_fluid[1] > 0:
		var my_input_inv = {}
		if data.has('fluid_input_inv'):
			my_input_inv = data.fluid_input_inv
		elif data.has('fluid_output_inv'):
			my_input_inv = data.fluid_output_inv
		
		var max_stack = 5
		if data.has('max_stack'):
			max_stack = data.max_stack
		else:
			var stack = JsonManager.search_for_item(data.waiting_for_fluid[0]).stack
			if (typeof(stack) == TYPE_STRING and stack != "default") or stack != null:
				max_stack = stack
		
		var can_add = InventoryManager.has_space_for_item(
			my_input_inv, 
			data.waiting_for_fluid[0], 
			data.waiting_for_fluid[1],
			data.inventory.item_inventory_size,
			max_stack,
		)
		
		if bool(can_add):
			FluidMovimentManager._move_fluid_to_target(data)
			data = MapDataManager.WorldTiles[data.map_pos]
	elif data.waiting_for_fluid:
		data.waiting_for_fluid = false
	await get_tree().physics_frame
