extends baseBlock
class_name buildingArea

@onready var sprites_with_shader = $Sprites_With_Shader
@onready var sprites_without_shader = $Sprites_Without_Shader


var toBuild : String = ""
var build_progress = 0.0
var shader = ShaderMaterial.new()

func _ready():
	life = 1
	data = data.duplicate(true) 
	$CollisionShape2D.shape.size = $Panel.size
	DroneManager.builds_for_drones.append([self, false])
	
	var loaded_textures = TextureManager._get_texture(data.texture)
	_load_sprites(loaded_textures)

func _update():
	shader.set("shader_parameter/build_progress", build_progress)

func _done():
	DroneManager.builds_for_drones.erase([self, true])
	
	var propPacked : PackedScene = load(toBuild)
	var propInstance = propPacked.instantiate()
	propInstance.data = data
	propInstance.global_position = global_position
	get_parent().add_child(propInstance)
	queue_free()

func _load_sprites(loaded_textures : Dictionary):
	var size = loaded_textures['size']
	var textures : Array[AtlasTexture] = loaded_textures.textures
	
	var tile_count = (textures[0].atlas.get_size() / size)
	
	shader.shader = load("res://resources/Shaders/BuildingSpot.gdshader")
	shader.set("shader_parameter/tile_count", tile_count)
	shader.set("shader_parameter/build_progress", .5)
	
	for c in sprites_with_shader.get_children():
		c.queue_free()
	
	for c in sprites_without_shader.get_children():
		c.queue_free()
	
	for texture in textures:
		var sprite_with_shader = Sprite2D.new()
		var sprite_without_shader = Sprite2D.new()
		
		sprite_with_shader.material = shader
		
		sprite_with_shader.texture = texture
		sprites_with_shader.add_child(sprite_with_shader)
		
		sprite_without_shader.texture = texture
		sprites_without_shader.add_child(sprite_without_shader)
	
	pass
