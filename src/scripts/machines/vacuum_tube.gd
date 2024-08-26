extends BaseMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	colisionShape = $CollisionShape2D
	
	_setup()
	await get_tree().create_timer(.01).timeout
	check_autotile_detectors()
	pass # Replace with function body.

func _process(delta):
	update()
	
	if inventory.size() > 0:
		$Item.texture = load(MainGlobal.item_sprite_path % inventory[0][0])
	else :
		$Item.texture = null
	
	if MainGlobal.BuildingMode:
		check_autotile_detectors()
	
	pass

func tick():
	pass

# Auto tile

func check_target_tile_position():
	var detectors = [$center/Detector_down, $center/Detector_left, $center/Detector_up, $center/Detector_right]
	var values_to_return = [false, false, false, false]
	
	for i in range(detectors.size()):
		var detector = detectors[i]
		var colider = detector.get_collider()
		
		if colider:
			var colider_props = (colider.global_position + (colider.out_direction * 32) == global_position) or colider.Type == types.Starter
			values_to_return[i] = (detector.is_colliding() and colider_props)
	
	return values_to_return

func check_autotile_detectors():
	
	
	var detectors = check_target_tile_position()
	
	match out_direction:
		Vector2.DOWN:
			detectors[0] = false
		Vector2.LEFT:
			detectors[1] = false
		Vector2.UP:
			detectors[2] = false
		Vector2.RIGHT:
			detectors[3] = false
	
	if name == "@StaticBody2D@23":
		print(detectors)
	
	$model/layer0.region_rect = auto_tile(Vector2(32,32), detectors, out_direction)
	$model/layer1.region_rect = $model/layer0.region_rect
	
	#for i : RayCast2D in $center.get_children():
	#	i.enabled = false

func auto_tile(size : Vector2 = Vector2(32,32), ray_casts : Array = [false, false, false, false], out_dir : Vector2 = Vector2.DOWN):
	const rects = {
		Vector2.DOWN : {
			#DOWN | LEFT | UP   | RIGHT
			[false, false, false, false] : Vector2(2, 1), # Nada Colide, estado inicial
			
			[false, false, true, false] : Vector2(2, 1), # Cima_para_Baixo
			[false, false, false, true] : Vector2(3, 2), # Direita_para_Baixo
			[false, true, false, false] : Vector2(2, 0), # Esquerda_para_Baixo
			
			[false, false, true, true] : Vector2(0, 3), # Cima_Direita_para_baixo
			[false, true, true, false] : Vector2(6, 2), # Cima_Esquerda_para_baixo
			
			[false, true, true, true] : Vector2(5, 0), # Cima_Esquerda_Direita_para_baixo
		},
		Vector2.LEFT : {
			#DOWN | LEFT | UP   | RIGHT
			[false, false, false, false] : Vector2(1, 2),  # Nada Colide, estado inicial 
			
			[false, false, false, true] : Vector2(1, 2), # Direita_para_esquerda
			[false, false, true, false] : Vector2(2, 2), # Cima_para_esquerda
			[true, false, false, false] : Vector2(4, 2), # Baixo_para_esquerda
			
			[false, false, true, true] : Vector2(6, 3), # Cima_Direita_para_esquerda
			[true, false, false, true] : Vector2(4, 0), # Baixo_Direita_para_esquerda
			
			[true, false, true, true] : Vector2(1, 2) # Cima_Baixo_Direita_para_esquerda
		},
		Vector2.UP : {
			#DOWN | LEFT | UP   | RIGHT 
			[false, false, false, false] : Vector2(0, 1), # Nada Colide, estado inicial 
			
			[true, false, false, false] : Vector2(0, 1), # Baixo_Para_cima
			[false, false, false, true] : Vector2(0, 2), # Esquerda_Para_cima
			[false, true, false, false] : Vector2(4, 3), # Direita_Para_cima
			
			[true, true, false, false] : Vector2(4, 1), # Baixo_Direita_Para_cima
			[true, false, false, true] : Vector2(5, 3), # Baixo_Esquerda_Para_cima
			
			[true, true, false, true] : Vector2(0, 1) # Baixo_Direita_Esquerda_Para_cima
		},
		Vector2.RIGHT : {
			#DOWN | LEFT | UP   | RIGHT
			[false, false, false, false] : Vector2(1, 0), # Nada Colide, estado inicial
			
			[false, true, false, false] : Vector2(1, 0), # Esquerda_para_direita
			[true, false, false, false] : Vector2(0, 0), # Baixo_para_direita
			[false, false, true, false] : Vector2(3, 3), # Cima_para_direita
			
			[false, true, true, false] : Vector2(3, 1), # Cima_Esquerda_para_direita
			[true, true, false, false] : Vector2(5, 2), # Baixo_Esquerda_para_direita
			
			[true, true, true, false] : Vector2(5, 1), # Baixo_Esquerda_Cima_para_direita
		}
	}
	
	if rects[out_dir].has(ray_casts):
		return Rect2(
			Vector2(
				rects[out_dir][ray_casts].x * size.x,
				rects[out_dir][ray_casts].y * size.y
			), 
			size
		)
	else:
		return Rect2(
			Vector2(
				rects[Vector2.DOWN][[false, false, true, false]].x * size.x,
				rects[Vector2.DOWN][[false, false, true, false]].y * size.y
			), 
			size
		)
