extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
@onready var sprite_2d: TextureRect = $Sprite2D

var scene = ""
var loading = false

func _ready() -> void:
	MapDataManager.tick.connect(_tick)

func _tick():
	if visible:
		sprite_2d.rotation_degrees += 2
	if loading:
		_update_progress()

func _load_screen(new_scene: String) -> void:
	if loading:
		print("Carregamento em andamento, aguarde...")
		return
	
	scene = new_scene
	loading = true
	ResourceLoader.load_threaded_request(scene)
	progress_bar.value = 0

func _set_label(text: String):
		label.text = text

func _set_progress_bar(value: float):
		progress_bar.value = value

func _update_progress():
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(scene, progress)
	
	
	# Atualiza a barra de progresso
	if progress.size() > 0:
		label.text = "Carregando Mundo..."
		progress_bar.value = progress[0] * 100
	
	# Verifica o status do carregamento
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_on_load_complete()
		ResourceLoader.THREAD_LOAD_FAILED:
			_on_load_failed()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Erro: Recurso inválido.")
			loading = false

func _on_load_complete():
	var packed = ResourceLoader.load_threaded_get(scene)
	if packed:
		get_tree().change_scene_to_packed(packed)
	else:
		print("Erro ao carregar a cena.")
	loading = false

func _on_load_failed():
	print("Falha ao carregar a cena.")
	loading = false
