extends Node2D

@export var ModelPositionMarker : Marker2D = null
@export var Indicador : MeshInstance2D = null
@export var colisionShape : CollisionShape2D = null

const Directions = [
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
]

enum Modes {
	brush,
	line
}

var prop_map : TileMapLayer = null
var astar : AStarGrid2D = null

var blockData : Dictionary = {}
var current_build_direction = 0 # index do direction
var astar_positions = {}
var mode : Modes = Modes.brush


func _ready() -> void:
	prop_map = get_parent().prop_map
	astar = get_parent().map_generator.astar

func _tick():
	if visible:
		_user_input()
		if get_parent().get_overlapping_bodies().size() > 0 or MapDataManager.get_prop_at(prop_map.local_to_map(get_global_mouse_position())):
			Indicador.modulate = Color("ff00065d")
		else:
			Indicador.modulate = Color("4e7eff5d")

func _user_input():
	if Input.is_action_just_pressed("rotate"):
		_rotate()
	elif Input.is_action_just_pressed("mouse_R"):
		blockData.clear()
		visible = false
	
	match mode:
		Modes.brush:
			if Input.is_action_just_pressed("mouse_L"):
				_build_instance(global_position)
			elif Input.is_action_pressed("mouse_L"):
				mode = Modes.line
		Modes.line:
			if Input.is_action_pressed("mouse_L") and not astar_positions.get('start', null):
				astar_positions['start'] = prop_map.local_to_map(get_global_mouse_position())
			elif Input.is_action_just_released("mouse_L"):
				astar_positions.clear()
				mode = Modes.brush
			elif astar_positions.get('start', null):
				astar_positions['end'] = prop_map.local_to_map(get_global_mouse_position())
				_build_on_path()

func _set_building(block_name : String):
	blockData = DataManager.BlocksData[block_name].duplicate()
	visible = true
	_load_model()

func _rotate():
	current_build_direction = (current_build_direction + 1) % Directions.size()
	_update_model()

func _load_model():
	if ModelPositionMarker.get_child_count() > 0:
		ModelPositionMarker.get_child(0).queue_free()
	
	var scenePath : String = blockData.get("prop_scene", "")
	if scenePath == "":
		return
	
	var packedScene : PackedScene = load(scenePath)
	var instance : BaseBlock = packedScene.instantiate()
	instance._setup(blockData.duplicate(), Directions[current_build_direction], prop_map.local_to_map(global_position))
	
	var size = Vector2(
		blockData.texture.texture_size.x,
		blockData.texture.texture_size.y
	)
	
	Indicador.mesh.size = Vector3(size.x, size.y, 0)
	Indicador.position = (size - Vector2(32, 32)) / 2
	colisionShape.shape.size = size - Vector2(2, 2)
	colisionShape.position = (size - Vector2(32, 32)) / 2
	
	instance._disable()
	ModelPositionMarker.add_child(instance)

func _update_model():
	var model : BaseBlock = ModelPositionMarker.get_child(0)
	model._update_pointingTo_and_mapPos(
		Directions[current_build_direction],
		prop_map.local_to_map(global_position)
	)

func _build_on_path():
	if astar_positions['end'] != astar_positions['start']:
		# Verificar se o AStar consegue acessar os pontos
		if astar.is_in_bounds(astar_positions['start'].x, astar_positions['start'].y) and astar.is_in_bounds(astar_positions['end'].x, astar_positions['end'].y):
			var path : Array = astar.get_id_path(astar_positions['start'], astar_positions['end'])
			
			for pos in path:
				_build_instance(prop_map.map_to_local(pos))
			astar_positions['start'] = astar_positions['end'] 
	pass

func _build_instance(instance_global_position : Vector2):
	var instance_in_game_pos : Vector2 = Vector2(prop_map.local_to_map(instance_global_position))
	
	if get_parent().get_overlapping_bodies().size() > 0 or MapDataManager.get_prop_at(instance_in_game_pos) or blockData.is_empty():
		return
	
	var scenePath : String = blockData.prop_scene
	if scenePath == "":
		return
	
	var texture_size_in_tiles = Vector2(blockData.texture.texture_size.x, blockData.texture.texture_size.y) / Consts.TILE_SIZE_32
	var positions_on_map = get_tile_positions(texture_size_in_tiles)
	
	positions_on_map.pop_front() # remover o index inicial, ele sempre sera (0, 0) oq não mudarai o valor de _position
	var resp = instantiate_block(instance_in_game_pos, positions_on_map)
	var instance = resp[0]
	var dt = resp[1]
	register_block_on_map(instance, dt, positions_on_map, instance_in_game_pos)
	
	instance.global_position = instance_global_position
	prop_map.add_child(instance)

func get_tile_positions(texture_size) -> Array:
	var positions_on_map = []
	
	for y in range(texture_size.y):
		var reverse = y % 2 == 1
		var x_range = range(texture_size.x - 1, -1, -1) if reverse else range(texture_size.x)
		for x in x_range:
			positions_on_map.append(Vector2(x, y))
	
	return positions_on_map

func get_adjacent_directions(position_on_map: Vector2) -> Array:
	var texture_size = Vector2(blockData.texture.texture_size.x, blockData.texture.texture_size.y) / Consts.TILE_SIZE_32
	var pointing_to = []
	
	if position_on_map.x == 0: pointing_to.append(Vector2(-1, 0))  # Esquerda
	if position_on_map.x == texture_size.x - 1: pointing_to.append(Vector2(1, 0))  # Direita
	if position_on_map.y == 0: pointing_to.append(Vector2(0, -1))  # Cima
	if position_on_map.y == texture_size.y - 1: pointing_to.append(Vector2(0, 1))  # Baixo
	
	return pointing_to

func register_block_on_map(instance, dt, positions_on_map, instance_pos):
	MapDataManager.register_prop(instance, instance_pos)
	var item_unloader_block_data = DataManager.BlocksData['item_unloader']
	
	if positions_on_map.size() > 0:
		instance._add_internalItemUnloader(
			item_unloader_block_data.duplicate(), 
			[Vector2(-1, 0), Vector2(0, -1)], 
			instance_pos,
			Vector2.ZERO
		)
	
	for position_on_map in positions_on_map:
		var map_position = instance_pos + position_on_map
		var pointing_to = get_adjacent_directions(position_on_map)
		
		instance._add_internalItemUnloader(
			item_unloader_block_data.duplicate(), 
			pointing_to, 
			map_position,
			position_on_map * Consts.TILE_SIZE_32
		)
		MapDataManager.register_prop(
			{
				"blockData": {
					"pointing_to": pointing_to, 
					"map_pos": map_position
				}, 
				"occupied_by": instance
			}, 
			map_position
		)

func instantiate_block(instance_in_game_pos: Vector2, positions_on_map):
	var packedScene: PackedScene = load(blockData.prop_scene)
	var instance: BaseBlock = packedScene.instantiate()
	var dt = blockData.duplicate()
	dt['positions_on_map'] = positions_on_map
	var pointing_to_main = [Vector2(-1, 0), Vector2(0, -1)] if positions_on_map.size() > 0 else Directions[current_build_direction]
	
	instance._setup(dt, pointing_to_main, instance_in_game_pos)
	
	return [instance, dt]
