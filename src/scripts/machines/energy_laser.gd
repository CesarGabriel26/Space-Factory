extends BaseBlock

@export_category("Energy")
@export var MaxTransmitionrange = 300

@onready var colisoes = $Colisoes
@onready var linhas = $Linhas

const max_capacity = 200  # A capacidade máxima de energia do bloco de transferência
var current_energy = 0  # A quantidade atual de energia armazenada no bloco
var connected_generators = []  # Lista de geradores conectados
var connected_transfer_blocks = []  # Lista de outros blocos de transferência conectados

func _ready():
	_setup()
	var rays : Array = colisoes.get_children()
	for ray : RayCast2D in rays:
		var dir = Vector2.ZERO
		
		if ray.target_position.x != 0:
			dir.x = (ray.target_position.x / ray.target_position.x) * MaxTransmitionrange
			if ray.target_position.x < 0:
				dir.x *= -1
		
		if ray.target_position.y != 0:
			dir.y = (ray.target_position.y / ray.target_position.y) * MaxTransmitionrange
			if ray.target_position.y < 0:
				dir.y *= -1
		
		ray.target_position = dir
	
	pass # Replace with function body.

func _process(delta):
	_transfer_energy_to_connected_blocks()
	_pull_energy_from_generators()
	show_rays()
	update()
	pass

# Função para transferir energia para outros blocos conectados
func _transfer_energy_to_connected_blocks():
	for block in connected_transfer_blocks:
		if current_energy > 0:
			var amount_to_transfer = min(current_energy, block.get_available_space())
			block.receive_energy(amount_to_transfer)
			current_energy -= amount_to_transfer

# Função para puxar energia dos geradores conectados
func _pull_energy_from_generators():
	for generator in connected_generators:
		if current_energy < max_capacity:
			var amount_to_pull = min(generator.get_available_energy(), max_capacity - current_energy)
			generator.remove_energy(amount_to_pull)
			current_energy += amount_to_pull

# Função para receber energia de outro bloco de transferência ou gerador
func receive_energy(amount):
	current_energy += amount
	if current_energy > max_capacity:
		current_energy = max_capacity

# Função que retorna quanto espaço de energia ainda tem disponível
func get_available_space():
	return max_capacity - current_energy

func show_rays():
	var rays : Array = colisoes.get_children()
	var lines : Array = linhas.get_children()
	
	for i in range(rays.size()):
		var ray : RayCast2D = rays[i]
		var line : Line2D = lines[i]
		
		ray.enabled = !preview
		
		# Tornar a linha visível apenas se o RayCast colidir
		line.visible = ray.is_colliding()
		
		if ray.is_colliding():
			var colider = ray.get_collider()
			if colider.Type == BaseBlock.types.Generator:
				connected_generators.append(colider)
			elif colider.Type not in [BaseBlock.types.Reciver, BaseBlock.types.Filter]:
				if !connected_transfer_blocks.has(colider):
					connected_transfer_blocks.append(colider)
			
			var collision_point = ray.get_collision_point()
			
			# O primeiro ponto da linha é a posição inicial do RayCast
			line.points[0] = ray.position
			
			# Calcula o ponto de colisão local
			var local_collision_point = ray.to_local(collision_point)
			
			# Adiciona um offset de 32 pixels na direção do RayCast
			var direction = (local_collision_point - ray.position).normalized()
			var offset = direction * 18
			
			# Define o ponto final com o offset
			line.points[1] = local_collision_point + offset

func send_block_data(send : bool):
	var max_life = 100
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
