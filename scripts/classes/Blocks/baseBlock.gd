extends StaticBody2D
class_name baseBlock

const explosionEffect = preload("res://resources/effects/ExplosionEffect/ExplosionEffect.tscn")
const building_spot = preload("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")

@export_category("Nodes")
@export var Sprites : Node2D
@export_category("Stats")
@export var life: float = 0.0
@export var explosion_radius : float = 1.0

var data = {
	"texture_cords" : Vector2(0,0)
} # informaçõs sobre o bloco
var a = false

func _load():
	life = data['life']
	_load_texture()

func _load_texture():
	var loaded_textures = TextureManager._get_texture(data.texture)
	
	var size = loaded_textures['size']
	var textures = loaded_textures.textures
	
	for c in Sprites.get_children():
		c.queue_free()
	
	for texture in textures:
		var Sprite = Sprite2D.new()
		
		Sprite.texture = texture
		Sprites.add_child(Sprite)

func _update_texture_rect(pos):
	for Sprite in Sprites.get_children():
		var t : AtlasTexture = Sprite.texture
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
