extends CPUParticles2D

@onready var area_2d = $Area2D

var damage_base = 100  # Dano máximo no centro da explosão

func explode():
	emitting = true
	await get_tree().create_timer(.1).timeout
	var overlapping_bodies = area_2d.get_overlapping_bodies()
	apply_damage_to_bodies(overlapping_bodies)

func apply_damage_to_bodies(bodies):
	for body in bodies:
		var distance = global_position.distance_to(body.global_position)
		var damage = damage_base * (1 - (distance / 128))  # Raio de 64, dano diminui com a distância
		if damage > 0:
			body.take_damage(damage)
		else:
			print(damage)
	
	await  get_tree().create_timer(1).timeout
	queue_free()
 
