extends Area2D
class_name BuilderTool

signal sprite_size_changed
signal new_build_placed

@onready var sprites = $Sprites
@onready var panel = $Panel
@onready var overlay_color = $OverlayColor
@onready var collision_shape_2d = $CollisionShape2D

var data = {}
var main_world : Node2D

const debug_builds = [
	"miner_mk1",
	"Router",
	"item_pipe_mk1"
]

var current = 0
var rot = 0
var out_dir = Vector2.UP

func _ready():
	DroneManager.load_new_build.connect(_load_build)

func _process(delta):
	if visible:
		_handle_input()
		$OverlayColor.visible = (get_overlapping_bodies().size() > 0)

# Função que gerencia input de rotação, troca de blocos e construção
func _handle_input():
	if !(get_overlapping_bodies().size() > 0):
		if Input.is_action_pressed("MouseL"):
			_build()
	
	if Input.is_action_pressed("MouseR"):
		visible = false
		set_process(false)
	
	if Input.is_action_just_pressed("rotate"):
		match rot:
			0: 
				rot = 90
			90: 
				rot = 180
			180: 
				rot = -90
			-90: 
				rot = 0
	
	sprites.rotation_degrees = rot

# Função para carregar os dados do bloco atual
func _load_build(_name : String = ""):
	visible = true
	set_process(true)
	if _name != "":
		data = JsonManager.get_on_json_by_keys("res://resources/data/json/blockData.json", [_name])
		if !data.is_empty() and data.texture:
			var loaded_textures = TextureManager._get_texture(data.texture)
			_load_sprites(loaded_textures)

# Função para carregar os sprites e ajustar tamanhos de colisão e overlays
func _load_sprites(loaded_textures : Dictionary):
	var size = loaded_textures['size']
	var textures = loaded_textures.textures
	emit_signal("sprite_size_changed", size)
	
	collision_shape_2d.shape.size = size - Vector2(2,2)
	panel.size = size
	overlay_color.size = size
	
	var offset_x = max(0, (size.x - 32) / 2)
	var offset_y = max(0, (size.y - 32) / 2)
	
	sprites.position = Vector2(offset_x, offset_y)
	collision_shape_2d.position = Vector2(offset_x, offset_y)
	
	for c in sprites.get_children():
		c.queue_free()
	
	TextureManager._add_sprites(textures, false, [], sprites)
	

# Atualiza a rotação e a direção de saída
func _update_rotation():
	match rot:
		0: 
			out_dir = Vector2.UP
		90: 
			out_dir = Vector2.RIGHT
		180: 
			out_dir = Vector2.DOWN
		-90: 
			out_dir = Vector2.LEFT

# Função principal para construção
func _build():
	if MapDataManager.WorldTiles.has(main_world._world_pos_to_world_map_pos(global_position)):
		return
	
	_update_rotation()
	var pos = main_world._world_pos_to_world_map_pos(global_position)
	var size = panel.size / 32
	var positions = []
	var out_dirs = _calculate_out_dirs(size)
	
	positions.append(pos)
	
	for y in range(size.y):
		var rg = range(size.x)
		
		if y == 1:
			rg = range(size.x -1, -1 , -1)
		
		for x in rg:
			var tile_pos = pos + Vector2(x, y)
			if tile_pos != pos:
				positions.append(tile_pos)
				MapDataManager.WorldTiles[tile_pos] = {
					'ref': pos,
					'map_pos': tile_pos,
					'out_dir': out_dirs[Vector2(x, y)]
				}
	
	if data.inventory.has_inventory.input:
		data['input_inv'] = {}
	if data.inventory.has_inventory.output:
		data['output_inv'] = {}
	if data.inventory.has_inventory.fluid_input:
		data['fluid_input_inv'] = {}
	if data.inventory.has_inventory.fluid_output:
		data['fluid_output_inv'] = {}
	
	if data.has("one_way"):
		data['out_dir'] = Vector2(out_dir.x, out_dir.y)
	else:
		data['out_dir'] = out_dirs[Vector2(0,0)]
	
	if data.inventory.has_inventory.input or data.inventory.has_inventory.output:
		data['waiting_for_item'] = false
	
	if data.inventory.has_inventory.fluid_input or data.inventory.has_inventory.fluid_output:
		data['waiting_for_fluid'] = false
	
	data['map_pos'] = pos
	data['building'] = true
	data['occupiedTiles'] = positions
	
	MapDataManager.WorldTiles[pos] = data
	
	# Carrega e posiciona o novo bloco na cena
	var prop = data.prop_scene
	if FileAccess.file_exists(prop):
		var BuildingSpot = load("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")
		var BuildingSpot_instance = BuildingSpot.instantiate()
		var target_node = main_world.get_node("Blocks")
		
		BuildingSpot_instance.global_position = global_position
		BuildingSpot_instance.rot = rot
		BuildingSpot_instance.world_ref = main_world
		BuildingSpot_instance.toBuild = prop
		BuildingSpot_instance.data = data.duplicate(true)
		BuildingSpot_instance.get_node("Panel").position = $Panel.position
		BuildingSpot_instance.get_node("Panel").size = $Panel.size
		data = data.duplicate(true)
		
		target_node.add_child(BuildingSpot_instance)
		emit_signal("new_build_placed")
		
		if !Input.is_action_pressed("shift"):
			visible = false
			set_process(false)
	else:
		printerr("Arquivo %s Não Existe na pasta" % prop)

# Função para calcular as direções de saída para cada posição relativa do bloco
func _calculate_out_dirs(size: Vector2) -> Dictionary:
	var out_dirs = {}
	
	for y in range(size.y):
		var rg = range(size.x)
		
		if y == 1:
			rg = range(size.x -1, -1 , -1)
		
		for x in rg:
			var dirs = []
			
			# Verifica as bordas e adiciona direções na ordem horária
			if x == 0: # Esquerda
				dirs.append(Vector2(-1, 0))
			if y == 0: # Cima
				dirs.append(Vector2(0, -1))
			if x == size.x - 1: # Direita
				dirs.append(Vector2(1, 0))
			if y == size.y - 1: # Baixo
				dirs.append(Vector2(0, 1))
			
			# Armazena as direções para cada posição relativa
			out_dirs[Vector2(x, y)] = dirs
	
	return out_dirs
