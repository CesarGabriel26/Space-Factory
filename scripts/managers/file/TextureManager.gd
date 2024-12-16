extends Node

#"texture": {
	#"texture_size": "(64, 64)",
	#"layers": [
		#{
			#"texture_file": "res://resources/images/SpriteSheets/props/Blocks_64x64.png",
			#"texture_cord": {
				#"x": 0,
				#"y": 3
			#}
		#},
		#{
			#"texture_file": "res://resources/images/SpriteSheets/props/Blocks_64x64.png",
			#"texture_cord": {
				#"x": 1,
				#"y": 3
			#},
			#"animation" : [
				#{
					#"prop" : "rotation_degrees",
					#"ope": "add",
					#"val": 200,
				#}
			#]
		#}
		#{
			#"node_type" : 0
			#"node_props": {
				#"global_position" : (1,1)
			#}
			#"animation" : [
				#{
					#"prop" : "rotation_degrees",
					#"ope": "add",
					#"val": 200,
				#}
			#]
		#}
	#]
#}

func _get_texture(texture_data : Dictionary) -> Dictionary :
	var texture_size = str_to_var("Vector2" + texture_data.texture_size)
	var layers = texture_data.layers
	
	var textures : Array
	
	for layer in layers:
		var texture_data_to_return = {}
	
		var texture_file = layer.texture_file
		var texture_cord = Vector2(layer.texture_cord.x, layer.texture_cord.y)
	
		texture_data_to_return['texture'] = _load_texture(texture_size, texture_file, texture_cord)
		
		if layer.has("animation"):
			texture_data_to_return['animation'] = layer.animation
		
		if layer.has("props"):
			texture_data_to_return['props'] = layer.props
		
		textures.append(texture_data_to_return)
	
	return {
		"size" : texture_size,
		"textures" : textures
	}
	pass

func _texture_cords_to_vector2_array(texture_cords : Array) -> Array[Vector2]:
	var cords_to_return : Array[Vector2] = []
	
	for texture_cord in texture_cords:
		cords_to_return.append(
			Vector2(texture_cord.x, texture_cord.y)
		)
	
	return cords_to_return

func _load_texture(texture_size : Vector2, texture_file : String, texture_cord : Vector2) -> AtlasTexture:
	if FileAccess.file_exists(texture_file):
		var texture_sheet = load(texture_file)
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture_sheet
		atlas_texture.region = Rect2(texture_cord * texture_size, texture_size)
		return atlas_texture
		
	else:
		printerr("Arquivo não encontrado:", texture_file)
		return null

func _add_sprites(textures: Array,with_animation : bool, animations : Array, Sprites : Node, shader : ShaderMaterial = null, useTextureRect : bool = false):
	var layer = 0
	for texture in textures:
		var Sprite
		
		if useTextureRect:
			Sprite = TextureRect.new()
			Sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
		else:
			Sprite = Sprite2D.new()
		
		Sprite.texture = texture.texture
		
		if shader:
			Sprite.material = shader

		
		if texture.has('animation'):
			for anim in texture.animation:
				animations.append(
					{
						"node" : Sprite,
						"propriedade" : anim.prop,
						"operacao": anim.ope,
						"valor": anim.val
					}
				)
		
		if texture.has("props"):
			for prop in texture.props:
				Sprite.set(prop, texture.props[prop])
		
		Sprite.z_index = layer
		Sprites.add_child(Sprite)
		layer += 1
