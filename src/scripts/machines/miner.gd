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
	active = check_can_run()
	
	$model/CPUParticles2D.emitting = active
	
	if active:
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
