extends Node

func write_to_json_file(file_path: String, data: Dictionary) -> void:
	# Converte os dados para string JSON
	var json_text = JSON.stringify(data, "\t") # Adiciona indentação para legibilidade
	
	# Abre o arquivo para escrita
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
		print("Dados escritos com sucesso em:", file_path)
	else:
		print("Erro ao abrir o arquivo para escrita:", file_path)

func read_from_json_file(file_path: String) -> Dictionary:
	# Verifica se o arquivo existe
	if FileAccess.file_exists(file_path):
		# Abre o arquivo para leitura
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
	
			# Converte o texto JSON em um dicionário
			var json = JSON.new()
			var error = json.parse(content)
			if error == OK:
				return json.data
			else:
				print("Erro ao parsear JSON:", error)
		else:
			print("Erro ao abrir o arquivo para leitura:", file_path)
	else:
		print("Arquivo não encontrado:", file_path)

	return {} # Retorna um dicionário vazio em caso de erro

func get_on_json_by_keys(file_path: String, keys : Array[String]):
	var data = read_from_json_file(file_path)
	var dt = data
	for key in keys:
		dt = dt[key]
	
	return dt
