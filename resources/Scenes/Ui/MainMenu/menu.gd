extends Control

@onready var single_player: Button = $CenterContainer/VBoxContainer/single_player
@onready var multi_player: Button = $CenterContainer/VBoxContainer/multi_player
@onready var center_container: CenterContainer = $CenterContainer
@onready var loading_screen: Control = $LoadingScreen

var building_map = false

func _ready() -> void:
	single_player.pressed.connect(_single_player)
	multi_player.pressed.connect(_multi_player)
	pass

func _process(delta: float) -> void:
	if not building_map:
		return
	
	var progress = (float(MapDataManager.world_gen_progress) / (MapDataManager.WORLD_SIZE * MapDataManager.WORLD_SIZE)) * 100
	
	loading_screen._set_label("Gerando Mundo...")
	loading_screen._set_progress_bar(progress)
	
	if progress >= 100:
		loading_screen._load_screen("res://resources/Scenes/MainWorld/main_world.tscn")
		building_map = false
	pass

func _single_player():
	center_container.visible = false
	loading_screen.visible = true
	building_map = true
	MapDataManager.generate_world_data_async()
	pass

func _multi_player():
	pass
