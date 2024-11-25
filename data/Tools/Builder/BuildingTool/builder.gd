extends Area2D
class_name BuilderTool

signal sprite_size_changed

@onready var sprites = $Sprites
@onready var panel = $Panel
@onready var overlay_color = $OverlayColor
@onready var collision_shape_2d = $CollisionShape2D


var data = {}
var main_world : Node2D

const debug_builds = [
	"miner_mk1",
	"shild_block"
]
var current = 0

func _ready():
	await get_tree().process_frame
	_load_build(debug_builds[current])

func _process(delta):
	if !(get_overlapping_bodies().size() > 0):
		if Input.is_action_pressed("MouseL"):
			_build()
	
	if Input.is_action_just_pressed("ui_up"):
		if current < debug_builds.size() - 1:
			current += 1
		else:
			current = 0
		_load_build(debug_builds[current])
	elif Input.is_action_just_pressed("ui_down"):
		if current >= 0:
			current -= 1
		else:
			current = (debug_builds.size() - 1)
		_load_build(debug_builds[current])
	
	$OverlayColor.visible = (get_overlapping_bodies().size() > 0)

func _load_build(_name : String = ""):
	if _name != "":
		data = JsonManager.get_on_json_by_keys(
			"res://resources/data/json/blockData.json", 
			[
				_name
			]
		)
	
		if !data.is_empty() and data.texture:
			var loaded_textures = TextureManager._get_texture(data.texture)
			_load_sprites(loaded_textures)

func _load_sprites(loaded_textures : Dictionary):
	var size = loaded_textures['size']
	var textures = loaded_textures.textures
	
	emit_signal("sprite_size_changed", size)
	
	collision_shape_2d.shape.size = size - Vector2(1,1)
	
	panel.size = size
	overlay_color.size = size
	
	overlay_color.position = (size / 2) * -1
	panel.position = (size / 2) * -1
	
	for c in sprites.get_children():
		c.queue_free()
	
	for texture in textures:
		var sprite = Sprite2D.new()
		
		sprite.texture = texture
		sprites.add_child(sprite)
	
	pass

func _build():
	if GlobalData.WorldTiles.has(main_world._world_pos_to_map_pos(global_position)):
		return
	else:
		var pos = main_world._world_pos_to_map_pos(global_position)
		
		if data.has_inventory.input:
			data['input_inv'] = {
				0: ['escoria', 5]
			}
		if data.has_inventory.output:
			data['output_inv'] = {
				0: ['escoria', 1]
			}
		if data.has_inventory.fluid_input:
			data['fluid_input_inv'] = [[null,0]] # o input de fluido só aceita um tipo de fluido por isso o tamanho maximo é 1
		if data.has_inventory.fluid_output:
			data['fluid_output_inv'] = [[null,0]]  # o output de fluido só aceita um tipo de fluido por isso o tamanho maximo é 1
		
		data['map_pos'] = pos
		
		GlobalData.WorldTiles[pos] = data
	
	var prop = data.prop_scene
	if FileAccess.file_exists(prop):
		var BuildingSpot = load("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")
		var BuildingSpot_instance = BuildingSpot.instantiate()
		var target_node = main_world.get_node("Blocks")
		
		BuildingSpot_instance.global_position = global_position
		BuildingSpot_instance.toBuild = prop
		BuildingSpot_instance.data = data
		BuildingSpot_instance.get_node("Panel").position = $Panel.position
		BuildingSpot_instance.get_node("Panel").size = $Panel.size
		
		target_node.add_child(BuildingSpot_instance)
		
	else:
		printerr("Arquivo %s Não Existe na pasta" % prop)
