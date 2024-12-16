extends Node

@export var enable: bool = false
@export var tile_map: TileMapLayer

var tile_map_size = Vector2(50, 50)  # Tamanho do mapa

var noise_temp: FastNoiseLite
var noise_humidity: FastNoiseLite

func _ready():
	if enable:
		randomize()
		noise_temp = FastNoiseLite.new()
		noise_temp.seed = randi()  # Semente aleatória para variedade
		noise_temp.frequency = 0.01  # Frequência inversamente proporcional ao período
		noise_temp.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH  # Tipo de ruído (exemplo)
		
		noise_humidity = FastNoiseLite.new()
		noise_humidity.seed = randi() + 1000  # Semente diferente para variar o padrão
		noise_humidity.frequency = 0.01
		noise_humidity.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		
		var world_data = generate_world()
		MapDataManager.WorldData = world_data
		update_tilemap_with_colors(world_data)

# Define uma cor personalizada para uma célula específica
func set_tile_color(coords: Vector2i, color: Color):
	tile_map.set_cell(coords, 0, Vector2(2, 0))
	var tile_data = tile_map.get_cell_tile_data(coords)
	if tile_data:
		tile_data.set_custom_data("modulate", color)
		tile_map.notify_runtime_tile_data_update()
	else:
		print("Nenhuma célula encontrada em", coords)
	
	_tile_data_runtime_update(coords, tile_data)

# Atualiza o tile no runtime para aplicar a cor
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData):
	if tile_data.get_custom_data("modulate"):
		var modulate_color = tile_data.get_custom_data("modulate")
		tile_data.modulate = modulate_color

# Gera os dados do mundo com temperatura e umidade
func generate_world():
	var world_data = []
	for y in range(tile_map_size.y):
		var row = []
		for x in range(tile_map_size.x):
			var temp = noise_temp.get_noise_2d(x / tile_map_size.x, y / tile_map_size.y)
			var humidity = noise_humidity.get_noise_2d(x / tile_map_size.x, y / tile_map_size.y)

			# Normaliza os valores de -1 a 1 para 0 a 1
			temp = (temp + 1) / 2
			humidity = (humidity + 1) / 2

			row.append({"temperature": temp, "humidity": humidity})
		world_data.append(row)
	return world_data

# Determina o bioma com base na temperatura e umidade
func determine_biome(temp, humidity):
	if temp > 0.7 and humidity < 0.3:
		return "Desert"
	elif temp > 0.7 and humidity >= 0.3:
		return "Savanna"
	elif temp > 0.4 and humidity > 0.7:
		return "Forest"
	elif temp <= 0.4 and humidity >= 0.5:
		return "Tundra"
	else:
		return "Plains"

# Determina a cor associada ao bioma
func determine_biome_color(temp, humidity):
	if temp > 0.7 and humidity < 0.3:
		return Color(1, 0.8, 0)  # Amarelo para deserto
	elif temp > 0.7 and humidity >= 0.3:
		return Color(0.9, 0.6, 0.3)  # Laranja para savana
	elif temp > 0.4 and humidity > 0.7:
		return Color(0, 0.8, 0.4)  # Verde para floresta
	elif temp <= 0.4 and humidity >= 0.5:
		return Color(0.6, 0.6, 1)  # Azul claro para tundra
	else:
		return Color(0.5, 1, 0.5)  # Verde claro para planícies

# Atualiza o TileMap com base nos biomas
func update_tilemap_with_colors(world_data):
	for y in range(tile_map_size.y):
		for x in range(tile_map_size.x):
			var coords = Vector2i(x, y)
			var tile_data = world_data[y][x]
			var biome_color = determine_biome_color(tile_data.temperature, tile_data.humidity)
			set_tile_color(coords, biome_color)
