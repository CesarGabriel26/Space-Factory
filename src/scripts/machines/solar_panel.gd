extends BaseMachine

const energy_per_second = 4
const max_capacity = 800

var current_voltage = 0

func _ready():
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_voltage < max_capacity:
		current_voltage += (energy_per_second * MainGlobal.light_level)
	else:
		current_voltage = max_capacity
	await get_tree().create_timer(1).timeout
	pass
