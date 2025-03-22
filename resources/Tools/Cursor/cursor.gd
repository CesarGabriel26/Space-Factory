extends Area2D

@onready var build_tool: Node2D = $BuildTool

@export var prop_map: TileMapLayer = null
@export var map_generator: Node = null

enum Modes {
	idle = 0,
	build,
	delete,
}

var freezed = false
var mode : Modes = Modes.idle

func _ready() -> void:
	MapDataManager.tick.connect(_tick)
	Signals.freeze_camera.connect(_freeze)

func _freeze(state: bool) -> void:
	freezed = state

func _tick() -> void:
	if not freezed:
		_move()
		build_tool._tick()

func _move() -> void:
	global_position = prop_map.map_to_local(
		prop_map.local_to_map(get_global_mouse_position())
	)
