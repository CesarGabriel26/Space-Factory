extends BaseMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	_setup()
	pass # Replace with function body.

func _process(delta):
	var canRun = check_can_run()
	
	$model/CPUParticles2D.emitting = canRun
	
	if canRun:
		$model/layer1.rotation_degrees += 50
		if $model/layer1.rotation_degrees > 360:
			$model/layer1.rotation_degrees = 0
	else:
		$model/layer1.rotation_degrees = lerpf($model/layer1.rotation_degrees, 0.0, .1)
		
	update_tick()
	pass

func check_can_run():
	var toReturn = false
	
	for i in range(NumSlots):
		if not Outinventory.has(i):
			return true
		else:
			if Outinventory[i][1] < MaxStack:
				toReturn = true
			else:
				toReturn = false
	
	return toReturn

func tick():
	var item = generate_resource()
	add_item_to_inventory(item, 1)

func generate_resource():
	randomize()
	var random_value = randf()  # Gera um valor entre 0 e 1
	var cumulative_probability = 0.0
	
	for resource in data["resources"]:
		cumulative_probability += data["resources"][resource]
		if random_value <= cumulative_probability:
			return resource
	return null  # Caso nenhum recurso seja encontrado (erro)
