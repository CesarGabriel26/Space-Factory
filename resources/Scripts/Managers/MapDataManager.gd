extends Node

signal tick
signal world_generated

const WORLD_SIZE = 64 #512
const CHUNK_SIZE = 32
const TILE_SIZE = 32
const world_gen_step = 32

# Lista de IDs de minérios
var ores = []

var worldTiles = {}
var worldProps = {}
var is_generating = false
var world_gen_progress = 0

# Ruído base
var elevation_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
var humidity_noise = FastNoiseLite.new()
var ocean_noise = FastNoiseLite.new()

# Máscara para evitar sobreposição de minérios
var ore_mask = {}

# Lista de ruídos para cada minério
var ore_noises = []
const ore_seeds = [
	-1875911699,
	-1894021870,
	-714862944,
	154059045
]

func _ready():
	var timer = Timer.new()
	timer.wait_time = 1.0 / 60.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_tick)
	add_child(timer)

func generate_world_data_async():
	elevation_noise.seed = 4444
	elevation_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	temperature_noise.seed = 1111
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	humidity_noise.seed = 2222
	humidity_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	# Ruído oceânico
	ocean_noise.seed = 3333
	ocean_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	ocean_noise.frequency = 0.002
	
	# Criar um FastNoise para cada minério
	ores = Consts.RESOURCES_ATLAS_TO_NAME.keys()
	
	ore_noises.clear()
	for i in range(ores.size()):
		var noise = FastNoiseLite.new()
		noise.seed = ore_seeds[i]
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		ore_noises.append(noise)

	# Resetar dados
	world_gen_progress = 0
	ore_mask.clear()
	worldTiles.clear()

	is_generating = true

func _process(_delta):
	if is_generating:
		generate_world_data_step()

func get_biome(temp: float, humidity: float) -> Vector2:
	if temp < -0.3:
		if humidity < -0.3:
			return Vector2(0, 2)  # Tundra
		elif humidity > 0.3:
			return Vector2(3, 3)  # Taiga
		return Vector2(1, 2)  # Montanha Fria

	elif temp > 0.3:
		if humidity < -0.3:
			return Vector2(0, 1)  # Deserto
		elif humidity > 0.3:
			return Vector2(6, 0)  # Pântano
		return Vector2(1, 1)  # Savana

	else:
		if humidity < -0.3:
			return Vector2(3, 2)  # Planalto seco
		elif humidity > 0.3:
			return Vector2(1, 3)  # Floresta tropical
		return Vector2(0, 3)  # Grama normal

func generate_world_data_step():
	var size = WORLD_SIZE
	var tiles_per_frame = world_gen_step
	
	for i in range(tiles_per_frame):
		if world_gen_progress >= size * size:
			is_generating = false
			world_generated.emit()
			return
		
		var x = world_gen_progress % size
		var y = world_gen_progress / size
		
		var elevation = elevation_noise.get_noise_2d(x, y)
		var temp_value = temperature_noise.get_noise_2d(x, y)
		var humidity_value = humidity_noise.get_noise_2d(x, y)
		var ocean_value = ocean_noise.get_noise_2d(x, y)
		
		# Misturar elevação com o ruído oceânico para criar mares
		var blended_elevation = elevation - ocean_value * 0.5
		
		# Determinar bioma com base em temperatura e umidade
		var terrain_id = get_biome(temp_value, humidity_value)
		
		if blended_elevation < -0.4:
			terrain_id = Vector2(0, 0)  # Mar profundo
		elif blended_elevation < -0.2:
			terrain_id = Vector2(1, 0)  # Água rasa
		
		var resource_id = Vector2(-1, -1)
		if blended_elevation > -0.2:
			# Tentar colocar minérios, verificando a máscara
			for o in range(ore_noises.size()):
				var noise_value = ore_noises[o].get_noise_2d(x, y)
				if noise_value > 0.6 and not ore_mask.has(Vector2i(x, y)):
					resource_id = ores[o]
					ore_mask[Vector2i(x, y)] = true
					break

		# Salvar dados no worldTiles
		worldTiles[Vector2i(x, y)] = {
			"terreno": terrain_id,
			"recurso": resource_id
		}

		world_gen_progress += 1

func _tick():
	emit_signal('tick')

### props function

func register_prop(block, pos: Vector2):
	worldProps[pos] = block

func remove_prop(pos: Vector2):
	if not worldProps.has(pos) : return
	
	var node : BaseBlock = worldProps[pos]
	node.queue_free()
	worldProps.erase(pos)

func get_prop_at(pos: Vector2):
	return worldProps.get(pos, null)

### props function

func get_resource_at(pos : Vector2i):
	return worldTiles[pos].recurso

func get_tile_at(pos : Vector2i):
	return worldTiles[pos].terreno
