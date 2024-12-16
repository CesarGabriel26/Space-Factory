extends Node

var auto_tile_nodes : Array[baseBlock] = []

#{ 
	#Vector2.DOWN: false, 
	#Vector2.LEFT: false, 
	#Vector2.UP: false, 
	#Vector2.RIGHT: false
#} : Vector2(2, 1), # Nada Colide, estado inicial

const check_pos = [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]
const tiles_positions = {
	Vector2.DOWN : {
		#DOWN | LEFT | UP   | RIGHT
		[false, false, false, false] : Vector2(2, 1), # Nada Colide, estado inicial
		
		[false, false, true, false] : Vector2(2, 1), # Cima_para_Baixo
		[false, false, false, true] : Vector2(3, 2), # Direita_para_Baixo
		[false, true, false, false] : Vector2(2, 0), # Esquerda_para_Baixo
		
		[false, false, true, true] : Vector2(3, 0), # Cima_Direita_para_baixo
		[false, true, true, false] : Vector2(6, 2), # Cima_Esquerda_para_baixo
		
		[false, true, false, true] : Vector2(7, 0), # Esquerda_Direita_para_baixo
		
		[false, true, true, true] : Vector2(5, 0), # Cima_Esquerda_Direita_para_baixo
	},
	Vector2.LEFT : {
		#DOWN | LEFT | UP   | RIGHT
		[false, false, false, false] : Vector2(1, 2),  # Nada Colide, estado inicial 
		
		[false, false, false, true] : Vector2(1, 2), # Direita_para_esquerda
		[false, false, true, false] : Vector2(2, 2), # Cima_para_esquerda
		[true, false, false, false] : Vector2(4, 2), # Baixo_para_esquerda
		
		[false, false, true, true] : Vector2(6, 3), # Cima_Direita_para_esquerda
		[true, false, false, true] : Vector2(4, 0), # Baixo_Direita_para_esquerda
		
		[true, false, true, false] : Vector2(7, 1), # Baixo_Cima_para_cima
	
		[true, false, true, true] : Vector2(6, 0) # Cima_Baixo_Direita_para_esquerda
	},
	Vector2.UP : {
		#DOWN | LEFT | UP   | RIGHT 
		[false, false, false, false] : Vector2(0, 1), # Nada Colide, estado inicial 
		
		[true, false, false, false] : Vector2(0, 1), # Baixo_Para_cima
		[false, false, false, true] : Vector2(0, 2), # Esquerda_Para_cima
		[false, true, false, false] : Vector2(4, 3), # Direita_Para_cima
		
		[true, true, false, false] : Vector2(4, 1), # Baixo_Direita_Para_cima
		[true, false, false, true] : Vector2(5, 3), # Baixo_Esquerda_Para_cima
		
		[false, true, false, true] : Vector2(7, 3), # Esquerda_Direita_para_cima
		
		[true, true, false, true] : Vector2(6, 1) # Baixo_Direita_Esquerda_Para_cima
	},
	Vector2.RIGHT : {
		#DOWN | LEFT | UP   | RIGHT
		[false, false, false, false] : Vector2(1, 0), # Nada Colide, estado inicial
		
		[false, true, false, false] : Vector2(1, 0), # Esquerda_para_direita
		[true, false, false, false] : Vector2(0, 0), # Baixo_para_direita
		[false, false, true, false] : Vector2(3, 3), # Cima_para_direita
		
		[false, true, true, false] : Vector2(3, 1), # Cima_Esquerda_para_direita
		[true, true, false, false] : Vector2(5, 2), # Baixo_Esquerda_para_direita
		
		[true, false, true, false] : Vector2(7, 2), # Baixo_Cima_para_cima
		
		[true, true, true, false] : Vector2(5, 1), # Baixo_Esquerda_Cima_para_direita
	}
}

func _get_auto_tilable_blocks():
	var n = get_tree().get_nodes_in_group('auto_tile')
	
	for node : baseBlock in n:
		var nodeData = node.data
		var res = [false, false, false, false]
		var nearby_blocks = MapDataManager._get_nearby_blocks(nodeData.map_pos)
		
		for i in range(nearby_blocks.size()):
			var nearby_block = nearby_blocks[i]
			var check_pos_is_diferent_from_out_dir 
			
			if typeof(nodeData.out_dir) == TYPE_ARRAY:
				check_pos_is_diferent_from_out_dir = (check_pos[i] not in nodeData.out_dir)
			else:
				check_pos_is_diferent_from_out_dir = (check_pos[i]!= nodeData.out_dir)
			
			if check_pos_is_diferent_from_out_dir:
				res[i] = _auto_tile_conditions(nodeData, nearby_block)
			else:
				res[i] = false
		
		var pos = tiles_positions[nodeData.out_dir][res] * str_to_var('Vector2' + nodeData.texture.texture_size)
		
		node._update_texture_rect(pos)

func _auto_tile_conditions(nodeData, nearby_block):
	#if nearby_block and nearby_block.has('ref'):
		#nearby_block = MapDataManager.WorldTiles[nearby_block.ref]
	
	if nearby_block == null or nodeData  == null:
		return false
	
	#elif nearby_block and nearby_block.has('ref'):
		#return true
	if typeof(nearby_block.out_dir) == TYPE_ARRAY:
		for out_dir in nearby_block.out_dir:
			if (out_dir + nearby_block.map_pos) == nodeData.map_pos:
				if (out_dir + nodeData.out_dir) == Vector2.ZERO:
					return false
	else:
		if (nearby_block.out_dir + nodeData.out_dir) == Vector2.ZERO:
			return false
	
		if (nearby_block.out_dir + nearby_block.map_pos) != nodeData.map_pos:
			return false
	
	
	return true
