extends Node

var BlocksData = {}
var ItensData = {}
var FluidData = {}

func _ready() -> void:
	BlocksData = read_all_JSON_to_dict("res://resources/blocks/Default/")
	ItensData = read_JSON("res://resources/Data/Json/items.json")
	_set_default_values()

func _set_default_values():
	for item in ItensData:
		var itemData = ItensData[item]
		var stack = itemData.get('stack', 1)
		if typeof(stack) == TYPE_STRING and stack == "default":
			ItensData[item].stack = 5

func read_JSON(json_file_path):
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var finish = json.parse_string(content)
	return finish

func write_JSON(json_file_path: String, data):
	var file = FileAccess.open(json_file_path, FileAccess.WRITE)
	if file:
		# Converte o dicionário em uma string JSON
		var json_string = JSON.stringify(data, "\t")
		# Escreve o JSON no arquivo
		file.store_string(json_string)
		file.close()
	else:
		printerr("Arquivo %s não existe" % json_file_path)

func read_all_JSON_to_dict(folder_path: String) -> Dictionary:
	var data = {}
	
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			var block_path = folder_path + folder_name
			var block_dir = DirAccess.open(block_path)
			
			if block_dir and block_dir.dir_exists(block_path):
				block_dir.list_dir_begin()
				var file_name = block_dir.get_next()
				
				while file_name != "":
					if file_name.ends_with(".json"):
						var json_path = block_path + "/" + file_name
						var file = FileAccess.open(json_path, FileAccess.READ)
						
						if file:
							var content = file.get_as_text()
							var json = JSON.new()
							var result = json.parse(content)
							
							if result == OK:
								var block_data = json.data
								
								# Ajustar os caminhos das texturas e cenas
								if block_data.has("prop_scene"):
									block_data["prop_scene"] = block_path + "/" + block_data["prop_scene"]
								
								if block_data.has("texture") and block_data["texture"].has("layers"):
									for layer in block_data["texture"]["layers"]:
										if layer.has("texture_file"):
											layer["texture_file"] = block_path + "/" + layer["texture_file"]
								
								data[folder_name] = block_data
							
							file.close()
					
					file_name = block_dir.get_next()
			
			folder_name = dir.get_next()
	return data
