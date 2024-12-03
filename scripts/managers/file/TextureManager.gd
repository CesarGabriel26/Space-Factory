extends Node

#"texture": {
	#"texture_size": "(32, 32)",
	#"layers": [
		#{
			#"texture_file": "res://resources/images/SpriteSheets/props/Blocks.png",
			#"texture_cord": {
				#"x": 0,
				#"y": 0
			#}
		#}
	#]
#},

func _get_texture(texture_data : Dictionary) -> Dictionary :
	var texture_size = str_to_var("Vector2" + texture_data.texture_size)
	var layers = texture_data.layers
	
	var textures : Array[AtlasTexture]
	
	for layer in layers:
		var texture_file = layer.texture_file
		var texture_cord = Vector2(layer.texture_cord.x, layer.texture_cord.y)
		textures.append(_load_texture(texture_size, texture_file, texture_cord))
	
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
	
