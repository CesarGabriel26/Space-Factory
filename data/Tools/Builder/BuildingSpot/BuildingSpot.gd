extends baseBlock
class_name buildingArea

@onready var sprites_with_shader = $Sprites_With_Shader
@onready var sprites_without_shader = $Sprites_Without_Shader
@onready var collision_shape_2d = $CollisionShape2D


var toBuild : String = ""
var build_progress = 0.0
var shader = ShaderMaterial.new()
var center = Vector2.ZERO
var rot = 0

func _ready():
	life = 1
	data = data.duplicate(true) 
	DroneManager.builds_for_drones.append([self, false])
	
	sprites_with_shader.rotation_degrees = rot
	sprites_without_shader.rotation_degrees = rot
	
	var loaded_textures = TextureManager._get_texture(data.texture)
	_load_sprites(loaded_textures)

func _update():
	shader.set("shader_parameter/build_progress", build_progress)

func _done():
	DroneManager.builds_for_drones.erase([self, true])
	
	data.erase('building')
	MapDataManager.WorldTiles[data.map_pos] = data
	
	var propPacked : PackedScene = load(toBuild)
	var propInstance = propPacked.instantiate()
	propInstance.data = data
	propInstance.world_ref = world_ref
	propInstance.global_position = global_position
	get_parent().add_child(propInstance)
	AutoTileManager._get_auto_tilable_blocks()
	queue_free()

func _load_sprites(loaded_textures : Dictionary):
	var size = loaded_textures['size']
	var textures : Array = loaded_textures.textures
	
	var tile_count = (textures[0]['texture'].atlas.get_size() / size)
	
	shader.shader = load("res://resources/Shaders/BuildingSpot.gdshader")
	shader.set("shader_parameter/tile_count", tile_count)
	shader.set("shader_parameter/build_progress", .5)
	
	var offset_x = max(0, (size.x - 32) / 2)
	var offset_y = max(0, (size.y - 32) / 2)
	
	collision_shape_2d.shape.size = size
	
	center = global_position + Vector2(offset_x, offset_y)
	sprites_with_shader.position = Vector2(offset_x, offset_y)
	sprites_without_shader.position = Vector2(offset_x, offset_y)
	collision_shape_2d.position = Vector2(offset_x, offset_y)
	
	for c in sprites_with_shader.get_children():
		c.queue_free()
	
	for c in sprites_without_shader.get_children():
		c.queue_free()
	
	TextureManager._add_sprites(textures, false, [], sprites_with_shader, shader)
	TextureManager._add_sprites(textures, false, [], sprites_without_shader)
	
	pass
