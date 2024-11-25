extends Node

#"texture": {
	#"texture_size": "(32, 32)"
	#"texture_file" : "res://resources/images/SpriteSheets/props/Blocks.png",
	#"texture_cords" : [
		#{
			#"x" : 0,
			#"y" : 0
		#},
	#]
#},

func _get_texture(texture_data : Dictionary) -> Dictionary :
	var texture_size = str_to_var("Vector2" + texture_data.texture_size)
	
	var texture_file = texture_data.texture_file
	
	var texture_cords = _texture_cords_to_vector2_array(texture_data.texture_cords)
	
	var textures = _load_textures(texture_size, texture_file, texture_cords)
	
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

func _load_textures(texture_size : Vector2, texture_file : String, texture_cords : Array[Vector2]) -> Array[AtlasTexture]:
	var textures : Array[AtlasTexture] = []
	
	if FileAccess.file_exists(texture_file):
		var texture_sheet = load(texture_file)
		
		for cord in texture_cords:
			var atlas_texture = AtlasTexture.new()
			
			atlas_texture.atlas = texture_sheet
			atlas_texture.region = Rect2(cord, texture_size)
			
			textures.append(atlas_texture)
	else:
		printerr("Arquivo não encontrado:", texture_file)
	
	return textures
