extends BaseBlock
class_name SolarPanel

const energy_per_second = 4  # Quantidade de energia gerada por segundo
const max_capacity = 800  # Capacidade máxima de armazenamento de cada painel

var current_voltage = 0  # Energia atual armazenada no painel
var connected_solar_panels = []  # Lista de painéis solares conectados

func _ready():
	_find_connected_panels()
	_setup()
	pass 

func _process(delta):
	_generate_energy(delta)
	_share_energy_with_connected_panels()
	update()
	pass

func get_available_energy():
	return current_voltage

func remove_energy(amount_to_pull : float):
	current_voltage -= amount_to_pull

# Função para gerar energia com base na luz
func _generate_energy(delta):
	if current_voltage < max_capacity:
		current_voltage += (energy_per_second * MainGlobal.light_level)
		if current_voltage > max_capacity:
			current_voltage = max_capacity

# Função que busca painéis solares conectados
func _find_connected_panels():
	connected_solar_panels.clear()  # Limpa a lista de conexões antigas
	for neighbor in get_neighbors():
		if neighbor is SolarPanel:
			connected_solar_panels.append(neighbor)

# Função para distribuir energia entre painéis conectados
func _share_energy_with_connected_panels():
	var total_energy = current_voltage
	var total_capacity = max_capacity

	# Soma a energia e a capacidade de todos os painéis conectados
	for panel in connected_solar_panels:
		total_energy += panel.current_voltage
		total_capacity += panel.max_capacity

	# Redistribui a energia de forma igualitária entre os painéis
	var energy_per_panel = total_energy / (connected_solar_panels.size() + 1)
	current_voltage = min(energy_per_panel, max_capacity)

	for panel in connected_solar_panels:
		panel.current_voltage = min(energy_per_panel, panel.max_capacity)

# Função que retorna os nós vizinhos
func get_neighbors() -> Array:
	var neighbors = []
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)] # Cima, baixo, esquerda, direita
	
	for dir in directions:
		var neighbor_position = global_position + (dir * 32) # Supondo que cada bloco tem 32x32 de tamanho
		var neighbor = get_neighbor_at_position(neighbor_position)
		if neighbor:
			neighbors.append(neighbor)
	
	return neighbors

# Função para verificar se há algum painel solar ou bloco de transferência na posição fornecida
func get_neighbor_at_position(position: Vector2) -> Node2D:
	for child in get_parent().get_children():
		if child is SolarPanel and child.global_position.distance_to(position) < 1:
			return child
	return null

func send_block_data(send : bool):
	var max_life = 100
	var send_data = {
		"name" : data["name"],
		"life" : life,
		"life_max" : max_life,
		"energy" : current_voltage,
		"energy_max" : max_capacity
	}
	
	if send:
		SignalManager.emit_signal("MouseHoveringBlock", send_data)
	else:
		SignalManager.emit_signal("MouseHoveringBlock", {})
	pass
