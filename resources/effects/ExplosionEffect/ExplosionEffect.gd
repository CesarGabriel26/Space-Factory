extends CPUParticles2D
class_name ExplosionEffect

signal explosionEnded

@onready var area_2d = $Area2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D

var damage_base = 100  # Dano máximo no centro da explosão
var radius = 32

func _ready():
	collision_shape_2d.shape.radius = radius

func explode():
	emitting = true
	await get_tree().create_timer(.1).timeout
	var overlapping_bodies = area_2d.get_overlapping_bodies()
	apply_damage_to_bodies(overlapping_bodies)

func apply_damage_to_bodies(bodies):
	for body in bodies:
		var distance = global_position.distance_to(body.global_position)
		var damage = damage_base * (1 - (distance / (radius * 2)))
		if damage > 0:
			body.receiveDemage(damage)
		else:
			print(damage)
	
	await  get_tree().create_timer(1).timeout
	queue_free()
 
