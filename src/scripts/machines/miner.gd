extends BaseMachine

@export var DebugResource = ""

func _ready():
	MouseDetectionPanel = $Panel
	ItemOutputsNode = $Outputs
	outInventory_node = $inventory/inv_grid
	BuildingModeInAndOutPreview = $"model/Inputs-outputs"
	
	_setup()
	pass 

func _process(delta):
	$model/CPUParticles2D.emitting = active
	
	if active:
		$model/layer1.rotation_degrees += 50
		if $model/layer1.rotation_degrees > 360:
			$model/layer1.rotation_degrees = 0
	else:
		$model/layer1.rotation_degrees = lerpf($model/layer1.rotation_degrees, 0.0, .1)
		
	update_tick()
	pass

func tick():
	if active:
		current_energy -= 100
		var item = generate_resource()
		add_item_to_inventory(item, 1, Outinventory)

func generate_resource():
	randomize()
	var random_value = randf()  # Gera um valor entre 0 e 1
	var cumulative_probability = 0.0
	
	if DebugResource != "":
		return DebugResource
	
	for resource in data["resources"]:
		cumulative_probability += data["resources"][resource]
		if random_value <= cumulative_probability:
			return resource
	return null  # Caso nenhum recurso seja encontrado (erro)

func send_block_data(send : bool):
	var send_data = {
		"name" : data["name"],
		"life" : life,
		"life_max" : max_life,
		"energy" : current_energy,
		"energy_max" : max_capacity
	}
	
	if send:
		SignalManager.emit_signal("MouseHoveringBlock", send_data)
	else:
		SignalManager.emit_signal("MouseHoveringBlock", {})
	pass
