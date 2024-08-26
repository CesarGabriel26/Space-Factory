extends BaseMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	_setup()
	pass # Replace with function body.

func _process(delta):
	#$model/layer1.rotation_degrees += 50
	#$model/CPUParticles2D.emitting = true
	
	update_tick()
	pass

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
