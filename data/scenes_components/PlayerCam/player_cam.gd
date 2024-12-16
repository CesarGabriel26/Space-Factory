extends Camera2D

@export_category("Properties")
@export var zoom_level = 0.5  # Incremento/decremento do zoom
@export var speed = 5.0      # Velocidade de movimento
@export var zoom_speed = 0.1 # Velocidade de transição do zoom
@export var zoom_min = .5   # Zoom mais próximo permitido
@export var zoom_max = 3   # Zoom mais distante permitido

var target_zoom: Vector2 = Vector2(1, 1)  # Zoom alvo
var MouseIsInteractingWithUIElement = false

func _ready():
	# Inicializa o zoom alvo com o valor atual.
	target_zoom = zoom
	
	# Configura o ProgressBar (opcional)
	var progress_bar = $UI/Container/ProgressBar
	progress_bar.min_value = zoom_min
	progress_bar.max_value = zoom_max
	progress_bar.value = target_zoom.x

func _physics_process(delta):
	# Movimento da câmera.
	var input = Input.get_vector("left", "right", "up", "down")
	global_position += input * speed
	
	if Input.is_action_just_pressed("build_menu"):
		$UI/Container/BuildMenu.visible = true
	
	# Atualiza o zoom com interpolação suave.
	zoom = zoom.lerp(target_zoom, zoom_speed)
	
	# Atualiza o valor do ProgressBar.
	$UI/Container/ProgressBar.value = target_zoom.x

func _input(event):
	if event.is_action_pressed("zoom-") and !MouseIsInteractingWithUIElement:
		# Verifica limite mínimo de zoom (mais perto).
		target_zoom.x = clamp(target_zoom.x - zoom_level, zoom_min, zoom_max)
		target_zoom.y = target_zoom.x
	elif event.is_action_pressed("zoom+") and !MouseIsInteractingWithUIElement:
		# Verifica limite máximo de zoom (mais longe).
		target_zoom.x = clamp(target_zoom.x + zoom_level, zoom_min, zoom_max)
		target_zoom.y = target_zoom.x

func MouseInteractingWithUIElement(Interacting: bool):
	MouseIsInteractingWithUIElement = Interacting
