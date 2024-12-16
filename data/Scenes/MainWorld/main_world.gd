extends Node2D

@onready var visible_map = $NavigationRegion2D/VisibleMap

@onready var navigation_region_2d = $NavigationRegion2D
@export var builderTool : BuilderTool

func _ready():
	navigation_region_2d.bake_navigation_polygon()
	builderTool.main_world = self
	

func _process(delta):
	if builderTool.visible:
		builderTool.global_position = _world_map_pos_to_world_pos(
			_world_pos_to_world_map_pos(get_global_mouse_position())
		)

func _world_map_pos_to_world_pos(pos: Vector2) -> Vector2:
	return visible_map.map_to_local(pos)

func _world_pos_to_world_map_pos(pos: Vector2) -> Vector2:
	return visible_map.local_to_map(pos)
