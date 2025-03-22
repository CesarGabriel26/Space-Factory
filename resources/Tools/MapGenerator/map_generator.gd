extends Node

const CHUNK_SCENE = preload("res://resources/tools/MapGenerator/chunk/chunk.tscn")

@export var chunks_container : Node2D = null
@export var player : Player = null

var astar : AStarGrid2D = AStarGrid2D.new()

func _ready():
	player.global_position = (Vector2.ONE * MapDataManager.WORLD_SIZE * MapDataManager.TILE_SIZE) / 2
	generate_chunks()
	setup_astar()

func generate_chunks():
	for chunk_x in range(MapDataManager.WORLD_SIZE / MapDataManager.CHUNK_SIZE):
		for chunk_y in range(MapDataManager.WORLD_SIZE / MapDataManager.CHUNK_SIZE):
			var chunk : Chunk = CHUNK_SCENE.instantiate()
			#chunk.modulate = Color(randf(), randf(), randf())
			chunk.name = "Chunk_%s_%s" % [chunk_x, chunk_y]
			chunk.position = Vector2(chunk_x, chunk_y) * MapDataManager.CHUNK_SIZE * MapDataManager.TILE_SIZE
			chunks_container.add_child(chunk)
			chunk.hide_maps()
			chunk.populate_chunk(Vector2i(chunk_x, chunk_y))

func setup_astar():
	astar.region = Rect2(Vector2.ZERO, Vector2(MapDataManager.WORLD_SIZE, MapDataManager.WORLD_SIZE))
	astar.cell_size = Vector2(MapDataManager.TILE_SIZE, MapDataManager.TILE_SIZE)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	#for x in range(MapDataManager.WORLD_SIZE):
		#for y in range(MapDataManager.WORLD_SIZE):
			#var coords = Vector2i(x, y)

func get_chunk(pos : Vector2):
	var chunk_x = int(pos.x / (MapDataManager.CHUNK_SIZE * MapDataManager.TILE_SIZE))
	var chunk_y = int(pos.y / (MapDataManager.CHUNK_SIZE * MapDataManager.TILE_SIZE))
	
	var chunk_name = "Chunk_%s_%s" % [chunk_x, chunk_y]
	
	return chunks_container.get_node(chunk_name)
