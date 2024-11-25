extends Node2D

@onready var tile_map = $GridMap
@onready var navigation_region_2d = $NavigationRegion2D

@export var builderTool : BuilderTool

func _ready():
	navigation_region_2d.bake_navigation_polygon()
	builderTool.main_world = self
	builderTool.sprite_size_changed.connect(_change_tile_size)

func _process(delta):
	# Atualiza a posição da ferramenta com base na grade
	builderTool.global_position = _map_pos_to_world_pos(
		_world_pos_to_map_pos(get_global_mouse_position())
	)

func _map_pos_to_world_pos(pos: Vector2) -> Vector2:
	return tile_map.map_to_local(pos)

func _world_pos_to_map_pos(pos: Vector2) -> Vector2:
	return tile_map.local_to_map(pos)

#func _draw():
	#var cell_size = tile_map.tile_set.tile_size
	#var tool_position = builderTool.global_position
	#var map_bounds = tile_map.get_used_rect()  # Limites das células usadas no TileMap
	#
	#for x in range(0, map_bounds.position.x + map_bounds.size.x):
		#for y in range(map_bounds.position.y, map_bounds.position.y + map_bounds.size.y):
			#var cell_world_pos = tile_map.map_to_local(Vector2(x, y))
	#
			## Calcula a distância até o builderTool
			#var distance = cell_world_pos.distance_to(tool_position)
	#
			## Desenha apenas se estiver dentro do alcance
			#if distance <= max_distance:
				#var alpha = 1.0 - (distance / max_distance)  # Transparência baseada na distância
				#var fade_color = cell_color
				#fade_color.a = 1  # Ajusta manualmente o canal alfa
	#
				#draw_rect(
					#Rect2(cell_world_pos, cell_size),  # Retângulo para a célula
					#fade_color,
					#false  # Apenas contorno
				#)

func _change_tile_size(size : Vector2):
	tile_map.tile_set.tile_size = size
	pass
