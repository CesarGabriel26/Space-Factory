extends Node3D

func _ready():
	for Bc in get_children():
		for Bt : StaticBody3D in Bc.get_children():
			Bt.input_event.connect(btn_input_event)
			Bt.mouse_entered.connect(btn_mouse_entered.bind(Bt))
			Bt.mouse_exited.connect(btn_mouse_exited.bind(Bt))

func btn_input_event(camera: Node, event: InputEvent, pos : Vector3, normal: Vector3, shape_idk : int):
	if event is InputEventMouseButton and event.pressed:
		var res = _get_button()
		if res:
			call_deferred(res)
	pass

func btn_mouse_entered(btn: Node3D):
	var tween : Tween = null
	tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(
		btn, "scale", Vector3(1.1, 1.1, 1.1),
		0.3
	)
	tween.play()
	await  tween.finished
	tween.kill()

func btn_mouse_exited(btn: Node3D):
	var tween : Tween = null
	tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(
		btn, "scale", Vector3(1, 1, 1),
		0.3
	)
	tween.play()
	await  tween.finished
	tween.kill()

func _get_button():
	var camera = get_viewport().get_camera_3d()
	if camera:
		# Calcula o raio de projeção com base na posição do mouse
		var ray_origin = camera.project_ray_origin(get_viewport().get_mouse_position())
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position())
		
		# Cria os parâmetros para o teste de colisão de raios
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_origin + ray_direction * 1000
		
		# Executa a interseção de raios
		var result = space_state.intersect_ray(query)
		# Verifica se o botão foi clicado
		if result and result.collider:
			return result.collider.function
		return false
	return false

## Funções dos botões

func configuracoes():
	pass

func um_jogador():
	get_tree().change_scene_to_file("res://data/main/main_world.tscn")
	pass

func multi_jogador():
	pass
