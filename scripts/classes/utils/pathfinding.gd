extends NavigationAgent2D
class_name PathfinfingAgent

var agent_sprite : Sprite2D = null
var rotation_offset : float = 0

func _setup():
	# Esses valores precisam ser ajustados para a velocidade do agente
	# e o layout de navegação.
	path_desired_distance = 4.0
	target_desired_distance = 4.0

func _set_movement_target(movement_target: Vector2):
	target_position = movement_target
	await get_tree().physics_frame

func _move(agent: Node2D, current_agent_position: Vector2, speed: float = 1.0):
	await get_tree().physics_frame
	if is_navigation_finished():
		return
	
	var next_path_position: Vector2 = get_next_path_position()
	
	# Faz com que o sprite olhe na direção do próximo ponto de navegação
	if agent_sprite:
		agent_sprite.look_at(next_path_position)
		agent_sprite.rotation_degrees += rotation_offset
	
	# Calcula a direção para o próximo ponto
	var direction = current_agent_position.direction_to(next_path_position)
	
	# Calcula a distância até o destino
	var distance_to_target = current_agent_position.distance_to(target_position)
	
	if agent is CharacterBody2D:
		agent.velocity = direction * speed
		agent.move_and_slide()
	
	elif agent is RigidBody2D:
		# Movimento para RigidBody2D usando força
		var force = direction * speed * agent.mass  # Ajuste conforme necessário
		var deceleration_force = -(agent.linear_velocity / 5)
		
		# Aplica uma força contrária para desacelerar ao se aproximar do destino
		if distance_to_target < 100.0:
			agent.apply_central_impulse(deceleration_force)
			await get_tree().create_timer(.5).timeout
			agent.moving = false
		else:
			agent.apply_central_impulse(force)
			agent.moving = true
