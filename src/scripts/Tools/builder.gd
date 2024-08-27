extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var model: Node2D = $model
@onready var area_2d = $Area2D

var current_rotation = 0
var tileMap : TileMap = null

func _ready() -> void:
	_load_building()
	pass

func _process(delta: float) -> void:
	if MainGlobal.BuildingMode:
		rotate_()
		build()
	pass

func build():
	var bodys = area_2d.get_overlapping_bodies()
	var coliding = bodys.size() > 0
	
	if Input.is_action_just_pressed("left click"):
		var pos = tileMap.map_to_local(tileMap.local_to_map(global_position))
		var prop = null
		
		if coliding:
			prop = bodys[0]
		else:
			prop = load("res://src/scenes/machines/%s.tscn" % MainGlobal.Building)
			prop = prop.instantiate()
			prop.global_position = pos
		
		prop.out_direction = rotation_to_out_direction()
		prop._reload()
		if !coliding:
			MainGlobal.Builds_Node.add_child(prop)

func rotate_():
	if Input.is_action_just_pressed("rotate"):
		current_rotation += 90
		
		if current_rotation > 180:
			current_rotation = -90
			
		_load_building()

func rotation_to_out_direction():
	match current_rotation:
		0:
			return Vector2.DOWN
		90:
			return Vector2.LEFT
		180:
			return Vector2.UP
		-90:
			return Vector2.RIGHT

func _load_building():
	if model.get_child_count() > 0:
		model.get_child(0).queue_free()
	
	var prop = load("res://src/scenes/machines/%s.tscn" % MainGlobal.Building)
	prop = prop.instantiate()
	prop.set_as_preview()
	prop.out_direction = rotation_to_out_direction()
	if prop.IsAutotile:
		prop.check_autotile_detectors()
	
	model.add_child(prop)
	pass
