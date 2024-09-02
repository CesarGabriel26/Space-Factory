extends Node

func _ready():
	MainGlobal.recipes = LerJson("res://src/data/recipes.json")

func LerJson(caminho_arquivo: String) -> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(caminho_arquivo)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return {}

func EscreverJson(caminho_arquivo: String, dados: Dictionary):
	var file = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		var json_text = json.print(dados)
		file.store_string(json_text)
		file.close()
	else:
		print("Erro ao abrir o arquivo para escrita: ", caminho_arquivo)

func LerJsonSave(caminho_arquivo: String):
	var json = JSON.new()
	var file = FileAccess.open(caminho_arquivo, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json_data = json.parse(json_text)
		file.close()
		if json_data.error == OK:
			return json_data.result
		else:
			print("Erro ao analisar JSON do save: ", json_data.error)
	return {}

func EscreverJsonSave(caminho_arquivo: String, propriedades: Dictionary):
	var json = JSON.new()
	var file = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	if file:
		var json_text = json.print(propriedades)
		file.store_string(json_text)
		file.close()
	else:
		print("Erro ao abrir o arquivo de save para escrita: ", caminho_arquivo)
