extends baseEntity
class_name baseDrone

signal starting_movement
signal stoping_movement

@export_category("Nodes")
@export var pathfinfingAgent : PathfinfingAgent
@export var sprite : Sprite2D
@export_category("Properties")
@export var speed : float = 300.0

var target_position : Vector2 = Vector2.ZERO
var time_to_reach_target = 0.0
var elapsed_time = 0.0
var busy = false
var moving = false : set = _set_moving;

func _set_moving(m):
	moving = m
	if m:
		emit_signal("starting_movement")
	else:
		emit_signal("stoping_movement")

func _setup():
	pathfinfingAgent._setup()
	pathfinfingAgent.agent_sprite = sprite
	pathfinfingAgent.rotation_offset = 90
	
	self.input_event.connect(_on_input_event)
	DroneManager.register_drone(self)  # Registra o drone no DroneManager

func _exit_tree():
	DroneManager.unregister_drone(self)  # Remove o drone ao sair

func _update(delta):
	if selected and Input.is_action_just_pressed("markPosition"):
		_set_target_position(get_global_mouse_position())
	
	if target_position != Vector2.ZERO:
		if !moving:
			moving = global_position.distance_to(target_position) > 100.0
	else:
		elapsed_time = 0.0
	
	if selected:
		$Sprite/Layer0/Layer1.self_modulate = Color.RED
	elif moving:
		$Sprite/Layer0/Layer1.self_modulate = Color.GREEN_YELLOW
	else:
		$Sprite/Layer0/Layer1.self_modulate = Color.WHITE

func _set_target_position(pos : Vector2):
	target_position = pos
	time_to_reach_target = (global_position.distance_to(target_position) / speed)
	elapsed_time = 0.0
	selected = false
	moving = true

func _move():
	if moving:
		pathfinfingAgent._set_movement_target(target_position)
		pathfinfingAgent._move(self, self.global_position, speed)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == MOUSE_BUTTON_LEFT:
			selected = true
		else:
			selected = false
