extends CanvasLayer

@export var player: Player
@onready var logistics: Panel = $Control/CenterContainer/logistics
@onready var build_menu: Control = $Control/build_menu

func _ready() -> void:
	Signals.show_inv_window.connect(show_inv_window)
	Signals.hide_inv_window.connect(hide_inv_window)
	MapDataManager.tick.connect(_tick)

func _tick():
	if Input.is_action_just_pressed("open_build_menu"):
		if build_menu.visible:
			hide_inv_window("BuildMenu")
		else:
			show_inv_window(null, "BuildMenu")

func show_inv_window(node: BaseInventoryBlock = null, window: String = ""):
	update_windows(window, true, node)

func hide_inv_window(window: String = ""):
	update_windows(window, false, null)

func update_windows(window: String, _visible: bool, node: BaseInventoryBlock = null):
	match window:
		"InfiniteChest":
			logistics.visible = _visible
			logistics.WindowNameToReturn = window
			logistics.NodeToModify = node if _visible else null
			if _visible:
				logistics._update()
	
		"BuildMenu":
			build_menu.visible = _visible if not build_menu.visible else false
			build_menu.WindowNameToReturn = window
	
	Signals.emit_signal("freeze_camera", _visible)
	player.freezed = _visible
