extends CharacterBody2D
class_name Player

@onready var camera: Camera2D = $Camera2D

const SPEED : float = 300.0
const JUMP_VELOCITY : float = -400.0
const MAX_ZOOM_OUT : float = 0.2
const MAX_ZOOM_IN : float = 4.0
const ZOOM_STEP : float = .2

var freezed = false
var current_zoom = 1

func _physics_process(delta: float) -> void:
	if freezed:
		return
	
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('scroll_down'):
		current_zoom -= ZOOM_STEP
	elif event.is_action_pressed('scroll_up'):
		current_zoom += ZOOM_STEP
		pass
	
	current_zoom = clamp(current_zoom, MAX_ZOOM_OUT, MAX_ZOOM_IN)
	camera.zoom = current_zoom * Vector2.ONE
