extends baseDrone
class_name BuilderDrone

@export var Laser : laser

var build_progress = 0.0
var building = false
var target : buildingArea = null

func _ready():
	_setup()

func _process(delta):
	_update(delta)
	
	# Atualiza o progresso da construção conforme o tempo de construção total
	if building and (build_progress * 2) < target.data["build_duration"]:
		build_progress += delta  # Incrementa pelo tempo entre frames
		# Calcula o progresso normalizado (0.5 a 1.0)
		var normalized_progress = (0.5 + (build_progress / target.data["build_duration"]) * 0.5) + .05
		
		if target:  # Garante que o target tem um Sprite
			target.build_progress = normalized_progress
			target._update()
	
		
	elif building:
		fire(false)
		building = false
		busy = false
		target._done()
		target = null

func _physics_process(delta):
	_move()

func fire(t : bool = true):
	Laser.ligado = t
	Laser.manual_target_position = target.global_position

func build(b):
	build_progress = 0.0
	stoping_movement.connect(at_target_position)
	_set_target_position(target.global_position)

func at_target_position():
	stoping_movement.disconnect(at_target_position)
	building = true
	fire()
