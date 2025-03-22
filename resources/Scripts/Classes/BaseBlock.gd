extends Node2D
class_name BaseBlock

signal pointingTo_and_mapPos_updated
signal model_region_rect_updated
const INTERNAL_ITEM_UNLOADER = preload("res://resources/Tools/InternalUsage/internal_item_unloader.tscn")

@export var VisibleNotifier : VisibleOnScreenNotifier2D = null
@export var ModelspritesNode : Node2D = null
@export var Model : Node2D = null
@export var internalItemUnloadersNode : Node2D = null

var blockData := {}

func _setup(default_data : Dictionary, pointing_to, map_pos : Vector2):
	if VisibleNotifier and Model:
		VisibleNotifier.screen_entered.connect(is_on_screen.bind(true))
		VisibleNotifier.screen_exited.connect(is_on_screen.bind(false))
	
	blockData = default_data
	_update_pointingTo_and_mapPos(pointing_to, map_pos)
	
	if default_data.get('inv_config', false):
		var inv = default_data.inv_config
		var inv_type = inv.inv_type
		
		match inv_type:
			"item_array":
				blockData["inventory"] = []
				blockData["moving_item"] = false
			"fluid":
				blockData["fluid_amount"] = 0
				blockData["neighbors"] = []
				blockData["capacity"] = 100.0
				blockData["transfer_speed"] = 3.0
			"item":
				blockData["inventory"] = {}
	
	if ModelspritesNode:
		var textures = LayeredTextureManager._load_model_texture(default_data).duplicate()
		
		for child in ModelspritesNode.get_children():
			ModelspritesNode.remove_child(child)  # Remove da árvore
			child.queue_free()  # Libera a memória
		
		for texture in textures:
			var sprite : Sprite2D = Sprite2D.new()
			sprite.texture = texture.atlas
			ModelspritesNode.add_child(sprite)
			
			# Aplicar propriedades
			for prop in texture.props:
				sprite.set(prop, texture.props[prop])
		
		MapDataManager.tick.connect(_animate_sprites)

func _disable():
	blockData['is_preview'] = true
	var collisionShape : CollisionShape2D = find_child("CollisionShape2D")
	collisionShape.disabled = true

func _update_pointingTo_and_mapPos(pointing_to, map_pos : Vector2 = Vector2.INF):
	if pointing_to:
		blockData['pointing_to'] = pointing_to
	if map_pos != Vector2.INF:
		blockData['map_pos'] = map_pos
	
	self.pointingTo_and_mapPos_updated.emit()

func is_on_screen(vis: bool):
	Model.visible = vis

func update_model_region_rect(region_rect : Rect2 = Rect2(Vector2.ZERO, Consts.TILE_SIZE_32)):
	for sprite : Sprite2D in ModelspritesNode.get_children():
		sprite.texture.region = region_rect
	model_region_rect_updated.emit()

func _update_tier(new_tier : int):
	if blockData.has('tier'):
		blockData.tier = new_tier
		var sprite = ModelspritesNode.get_child(0)
		
		if sprite:
			sprite.modulate = Color(Consts.TIER_COLORS[new_tier])

func _animate_sprites():
	if blockData.get('is_preview'): return
	
	var layers = blockData.texture.layers
	for i in range(layers.size()):
		var layer = layers[i]
		
		if layer.has("animation"):
			var animations : Dictionary = layer.animation
			var properties_to_animate = animations.keys()
			
			for prop_to_animate in properties_to_animate:
				var speed = animations[prop_to_animate].speed
				var loop = animations[prop_to_animate].loop
				var finished = animations[prop_to_animate].get('finished', false)
				
				
				if not loop and finished:
					continue
				
				match prop_to_animate:
					"rotate":
						var node : Node2D = ModelspritesNode.get_child(i)
						if node.rotation_degrees > 360:
							node.rotation_degrees = 0
						
						node.rotation_degrees += speed
						if not loop:
							animations[prop_to_animate].finished = true
						
						pass

func _add_internalItemUnloader(default_data, pointing_to, map_pos : Vector2, internal_pos : Vector2):
	if not internalItemUnloadersNode : return
	
	var node : InternalItemUnloader = INTERNAL_ITEM_UNLOADER.instantiate()
	node._setup(default_data, pointing_to, map_pos)
	node.target = self
	node.position = internal_pos
	
	internalItemUnloadersNode.add_child(node)
	pass
