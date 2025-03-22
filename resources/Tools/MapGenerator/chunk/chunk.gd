extends Node2D
class_name Chunk

@export var FloorLayer : TileMapLayer = null
@export var ResourcesLayer : TileMapLayer = null
@export var VisibleNotifier : VisibleOnScreenNotifier2D = null

func populate_chunk(chunk_pos : Vector2i):
	VisibleNotifier.rect = Rect2(Vector2.ZERO, (Vector2.ONE * MapDataManager.CHUNK_SIZE * MapDataManager.TILE_SIZE))
	
	for x in range(MapDataManager.CHUNK_SIZE):
		for y in range(MapDataManager.CHUNK_SIZE):
			var world_x = chunk_pos.x * MapDataManager.CHUNK_SIZE + x
			var world_y = chunk_pos.y * MapDataManager.CHUNK_SIZE + y
			var tile_data = MapDataManager.worldTiles.get(Vector2i(world_x, world_y), null)
			
			if tile_data:
				# Definir terreno
				FloorLayer.set_cell(Vector2i(x, y), 0, tile_data["terreno"])
			
				# Definir recurso (se existir)
				if tile_data["recurso"] != Vector2(-1, -1):
					ResourcesLayer.set_cell(Vector2i(x, y), 0, tile_data["recurso"], randi_range(1, 3))

func hide_maps():
	FloorLayer.visible = false
	ResourcesLayer.visible = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	FloorLayer.visible = false
	ResourcesLayer.visible = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	FloorLayer.visible = true
	ResourcesLayer.visible = true
