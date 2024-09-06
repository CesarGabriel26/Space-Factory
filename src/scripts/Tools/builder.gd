extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var model: Node2D = $model
@onready var area_2d = $Area2D
@onready var outlines = $outlines
@onready var collision_shape_2d = $Area2D/CollisionShape2D

var current_rotation = 0
var tileMap : TileMap = null
var canBuild = true
var data = {
	"delay" : 1,
	"tier" : 2,
	"resources" : {
		"minerio_de_cobre" : 0.5,  # 50% de chance
		"minerio_de_ferro" : 0.2,  # 20% de chance
		"minerio_de_ouro"  : 0.15, # 15% de chance
		"minerio_de_zinco" : 0.15  # 15% de chance
	}
}
var _build = ""


func _ready() -> void:
	SignalManager.MouseEnteredUI.connect(set_can_build)
	SignalManager.BuildSelected.connect(_load_building)
	pass

func _process(delta: float) -> void:
	if MainGlobal.BuildingMode and canBuild:
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
			var Machines = JsonManager.LerJson("res://src/data/maquinas.json")
			var Machine = Machines[_build]
						
			prop = load(Machine["source"])
			prop = prop.instantiate()
			prop.global_position = pos
			prop.data = Machine["data"]
			
		if prop is BaseMachine:
			prop.out_direction = rotation_to_out_direction()
			prop._reload()
		if !coliding:
			MainGlobal.Builds_Node.add_child(prop)

func rotate_():
	if Input.is_action_just_pressed("rotate"):
		current_rotation += 90
		
		if current_rotation > 180:
			current_rotation = -90
			
		_load_building(_build)

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

func _load_building(build):
	if model.get_child_count() > 0:
		model.get_child(0).queue_free()
	
	var Machines = JsonManager.LerJson("res://src/data/maquinas.json")
	var Machine = Machines[build]
	var size = Machines[build]["menu_icon"]["size"]
	
	var lines = outlines.get_children()
	lines[0].position.y = size[0]
	lines[1].position.x = size[1]
	collision_shape_2d.shape.size = Vector2(size[0] - 2, size[1] - 2)
	collision_shape_2d.position = Vector2(size[0] / 4, size[1] / 4)
	
	if collision_shape_2d.position == Vector2(8,8):
		collision_shape_2d.position = Vector2.ZERO
	
	_build = build
	var prop = load(Machine["source"])
	
	prop = prop.instantiate()
	prop.data = Machine["data"]
	
	prop.set_as_preview()
	
	if prop is BaseMachine:
		prop.out_direction = rotation_to_out_direction()
		prop._reload()
		if prop.IsAutotile:
			prop.check_autotile_detectors()
	
	model.add_child(prop)
	pass

func set_can_build(can : bool):
	canBuild = !can
