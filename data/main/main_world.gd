extends Node2D

@onready var tile_map = $TileMap

func _map_pos_to_word_pos(pos : Vector2):
	return tile_map.map_to_local(pos)

func _word_pos_to_map_pos(pos : Vector2):
	return tile_map.local_to_map(pos)
