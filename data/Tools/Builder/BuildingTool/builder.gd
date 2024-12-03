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
	"shild_block",
	"item_pipe_mk1"
]

var current = 0
var rot = 0
var out_dir = Vector2.UP

func _ready():
	await get_tree().process_frame
	_load_build(debug_builds[current])

func _process(delta):
	_handle_input()
	$OverlayColor.visible = (get_overlapping_bodies().size() > 0)

# Função que gerencia input de rotação, troca de blocos e construção
func _handle_input():
	if !(get_overlapping_bodies().size() > 0):
		if Input.is_action_pressed("MouseL"):
			_build()
	
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
	
	if Input.is_action_just_pressed("ui_up"):
		current = (current + 1) % debug_builds.size()
		_load_build(debug_builds[current])
	elif Input.is_action_just_pressed("ui_down"):
		current = (current - 1 + debug_builds.size()) % debug_builds.size()
		_load_build(debug_builds[current])

# Função para carregar os dados do bloco atual
func _load_build(_name : String = ""):
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
	
	for texture in textures:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprites.add_child(sprite)

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
	
	for x in range(size.x):
		for y in range(size.y):
			var tile_pos = pos + Vector2(x, y)
			positions.append(tile_pos)
			MapDataManager.WorldTiles[tile_pos] = {
				'ref': pos,
				'out_dir': out_dirs[Vector2(x, y)]
			}
	
	if data.has_inventory.input:
		data['input_inv'] = {}
	if data.has_inventory.output:
		data['output_inv'] = {}
	if data.has_inventory.fluid_input:
		data['fluid_input_inv'] = {}
	if data.has_inventory.fluid_output:
		data['fluid_output_inv'] = {}
	
	# Atualiza as informações do bloco principal
	data['out_dir'] = out_dirs[Vector2(0, 0)]
	data['map_pos'] = pos
	data['occupiedTiles'] = positions

	# Carrega e posiciona o novo bloco na cena
	var prop = data.prop_scene
	if FileAccess.file_exists(prop):
		var BuildingSpot = load("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")
		var BuildingSpot_instance = BuildingSpot.instantiate()
		var target_node = main_world.get_node("Blocks")
		
		BuildingSpot_instance.global_position = global_position
		BuildingSpot_instance.rot = rot
		BuildingSpot_instance.toBuild = prop
		BuildingSpot_instance.data = data.duplicate(true)
		BuildingSpot_instance.get_node("Panel").position = $Panel.position
		BuildingSpot_instance.get_node("Panel").size = $Panel.size
		data = data.duplicate(true)
		
		target_node.add_child(BuildingSpot_instance)
		emit_signal("new_build_placed")
	else:
		printerr("Arquivo %s Não Existe na pasta" % prop)

# Função para calcular as direções de saída para cada posição relativa do bloco
func _calculate_out_dirs(size: Vector2) -> Dictionary:
	var out_dirs = {}
	
	for x in range(size.x):
		for y in range(size.y):
			var dirs = []
			
			# Adiciona direções nas bordas
			if x == 0:
				dirs.append(Vector2(-1, 0)) # Esquerda
			elif x == size.x - 1:
				dirs.append(Vector2(1, 0)) # Direita
			
			if y == 0:
				dirs.append(Vector2(0, -1)) # Cima
			elif y == size.y - 1:
				dirs.append(Vector2(0, 1)) # Baixo
			
			out_dirs[Vector2(x, y)] = dirs
	
	return out_dirs
