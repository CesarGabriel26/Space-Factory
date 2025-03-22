extends BaseBlock
class_name FluidPipe

func _ready() -> void:
	if blockData.get('is_preview'): return
	MapDataManager.tick.connect(_tick)
	model_region_rect_updated.connect(connect_pipe)

func _tick():
	pull_from_tank()
	distribute_fluid()

func pull_from_tank():
	var neighbors = blockData.neighbors
	var capacity = blockData.capacity
	var fluid_amount = blockData.fluid_amount
	
	for neighbor in neighbors:
		if typeof(neighbor) == TYPE_DICTIONARY:
			neighbor = neighbor.occupied_by
		
		if neighbor is FluidTank:  # Se for um tanque
			var needed = capacity - fluid_amount  # Quanto falta no tubo
			if needed > 0:
				var pulled = neighbor.withdraw(needed)  # Puxa o máximo disponível
				fluid_amount += pulled

func distribute_fluid():
	var neighbors = blockData.neighbors
	
	var total_pressure = blockData.fluid_amount / blockData.capacity
	for neighbor in neighbors:
		if neighbor is FluidPipe or neighbor is FluidTank:
			var neighbor_pressure = neighbor.blockData.fluid_amount / neighbor.blockData.capacity
			if total_pressure > neighbor_pressure:
				var transfer_amount = (total_pressure - neighbor_pressure) * blockData.transfer_speed
				transfer_amount = min(transfer_amount, blockData.fluid_amount)
				blockData.fluid_amount -= transfer_amount
				neighbor.blockData.fluid_amount += transfer_amount
	
	ModelspritesNode.get_child(1).modulate = Color(0, 0.396, 1, total_pressure)

func connect_pipe():
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var neighbors = blockData.neighbors
	
	for dir in dirs:
		var prop = MapDataManager.get_prop_at(blockData.map_pos + dir)
		
		if typeof(prop) == TYPE_DICTIONARY:
			prop = prop.occupied_by
		
		if prop and prop not in neighbors:
			neighbors.append(prop)


"""
extends BaseBlock
class_name FluidPump

var pump_rate = 10.0  # Quantidade de fluido movida por tick

func _tick():
	var back_pipe = MapDataManager.get_prop_at(blockData.map_pos - blockData.pointing_to)
	var front_pipe = MapDataManager.get_prop_at(blockData.map_pos + blockData.pointing_to)
	
	if back_pipe and front_pipe:
		var pulled = back_pipe.withdraw(pump_rate)
		front_pipe.insert(pulled)
"""
