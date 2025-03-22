extends Node

func _create_atlas(texture_size : Dictionary, layer : Dictionary):
	var texture_file = load(layer.texture_file)
	var texture_cord = layer.get("texture_cord")
	
	var atlasTexture = AtlasTexture.new()
	atlasTexture.atlas = texture_file
	if texture_cord:
		atlasTexture.region = Rect2(
			Vector2(texture_cord.x, texture_cord.y) * Vector2(texture_size.x, texture_size.y), 
			Vector2(texture_size.x, texture_size.y)
		)
	
	return {
		'atlas': atlasTexture,
		'animation' : layer.get('animation', {}),
		'props': layer.get('props', {})
	}
	pass

func _load_model_texture(blockData : Dictionary) -> Array[Dictionary]:
	var texture_data = blockData.texture
	var texture_size = texture_data.texture_size
	var texture_layers = texture_data.layers
	
	var textures : Array[Dictionary] = []
	
	for layer in texture_layers:
		textures.push_back(_create_atlas(texture_size, layer))
	
	return textures
