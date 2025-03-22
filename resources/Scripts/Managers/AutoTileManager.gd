extends Node

const a = {
	Vector2.RIGHT : {
		# 2 representa o tile de itemLU no modo de load
		#cima  baixo  esquerda  direita
		[false, false, false, false] : Vector2(0, 0),
		
		[false, false, true, false] : Vector2(0, 0),
		[false, true, false, false] : Vector2(1, 0),
		[true, false, false, false] : Vector2(2, 0),
		
		[true, true, false, false] : Vector2(3, 0), 
		[false, true, true, false] : Vector2(4, 0), 
		[true, false, true, false] : Vector2(5, 0),
		
		[true, true, true, false] : Vector2(6, 0),
	},
	Vector2.DOWN : {
		# 2 representa o tile de itemLU no modo de load
		#cima  baixo  esquerda  direita
		[false, false, false, false] : Vector2(0, 1),
		
		[true, false, false, false] : Vector2(0, 1),
		[false, false, true, false] : Vector2(1, 1),
		[false, false, false, true] : Vector2(2, 1),
		
		[false, false, true, true] : Vector2(3, 1), 
		[true, false, false, true] : Vector2(4, 1), 
		[true, false, true, false] : Vector2(5, 1),
		
		[true, false, true, true] : Vector2(6, 1),
	},
	Vector2.LEFT : {
		# 2 representa o tile de itemLU no modo de load
		#cima  baixo  esquerda  direita
		[false, false, false, false] : Vector2(0, 2), # para esquerda
		
		[false, false, false, true] : Vector2(0, 2), # direita para esquerda
		[true, false, false, false] : Vector2(1, 2), # cima para esquerda
		[false, true, true, false] : Vector2(2, 2), # baixo para esquerda
		
		[true, true, false, false] : Vector2(3, 2), 
		[false, true, false, true] : Vector2(4, 2), 
		[true, false, false, true] : Vector2(5, 2),
		
		[true, true, false, true] : Vector2(6, 2), # cima, baixo e direita para esquerda
	},
	Vector2.UP : {
		# 2 representa o tile de itemLU no modo de load
		#cima  baixo  esquerda  direita
		[false, false, false, false] : Vector2(0, 3), # para cima
		
		[false, true, false, false] : Vector2(0, 3), # baixo para cima
		[false, false, false, true] : Vector2(1, 3), # direita para cima
		[false, false, true, false] : Vector2(2, 3), # esquerda para cima
		
		[false, false, true, true] : Vector2(3, 3), # direita e esquerda para cima
		[false, true, false, true] : Vector2(4, 3), # baixo e direita para cima
		[false, true, true, false] : Vector2(5, 3), # baixo e esquerda para cima
		
		[false, true, true, true] : Vector2(6, 3), # baixo, esquerda e direita para cima
	}
}

func _ready() -> void:
	MapDataManager.tick.connect(update_autotile)
	pass

func get_rect_position(blockData : Dictionary, matrix : Array = [false, false, false, false]):
	var auto_tile = blockData.auto_tile
	var possibilidades = auto_tile.get(
		"default", 
		auto_tile.get(str(blockData.pointing_to))
	)
	
	if possibilidades and typeof(possibilidades) == TYPE_DICTIONARY:
		if !possibilidades.has(str(matrix)):
			matrix = [false, false, false, false]
		
		return str_to_var("Vector2" + possibilidades[str(matrix)])
	
	return Vector2.ZERO

func default_get_rect_matrix(blockData : Dictionary):
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var result = []
	
	for direction in directions:
		if direction == blockData.pointing_to:
			result.push_back(false)
			continue
		
		var target_block = MapDataManager.get_prop_at(direction + blockData.map_pos)
		if not target_block:
			result.append(false)
			continue
		
		if target_block is ItemLu and target_block.blockData.action_type == "load":
			result.append( 
				(target_block.blockData.pointing_to * -1) + target_block.blockData.map_pos == blockData.map_pos
			)
		else:
			var match_ = false
			
			if typeof(target_block.blockData.pointing_to) == TYPE_ARRAY:
				for pointing_to in target_block.blockData.pointing_to:
					match_ = pointing_to + target_block.blockData.map_pos == blockData.map_pos
					if match_:
						break
			else:
				match_ = target_block.blockData.pointing_to + target_block.blockData.map_pos == blockData.map_pos
			
			result.append(match_)
	
	return result

func pipe_white_list(target):
	if typeof(target) == TYPE_DICTIONARY:
		target = target.occupied_by
	
	if target is FluidPipe : return true
	if target is FluidTank : return true
	
	return false

func pipe_get_rect_matrix(blockData : Dictionary):
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	var result = []
	
	for direction in directions:
		var target_block = MapDataManager.get_prop_at(direction + blockData.map_pos)
		if target_block and pipe_white_list(target_block):
			result.append(true) 
		else:
			result.append(false)
	return result

func update_autotile():
	var nodes : Array = get_tree().get_nodes_in_group("auto_tile")
	
	for node in nodes:
		var blockData = node.blockData
		var matrix : Array
		
		if node is FluidPipe:
			matrix = pipe_get_rect_matrix(blockData)
		else:
			matrix = default_get_rect_matrix(blockData)
		
		if blockData.get('is_preview', false):
			matrix = [false, false, false, false]
		
		var rect_position : Vector2 = get_rect_position(blockData, matrix)
		node.update_model_region_rect(Rect2(rect_position * Consts.TILE_SIZE_32, Consts.TILE_SIZE_32))
