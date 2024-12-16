extends Node

# Condição dinâmica para verificar os requisitos
func check_conditions(require, environment_data):
	for condition_entry in require:
		var condition_type = condition_entry.get("type", "")
		var query = condition_entry.get("query", {})
		
		match condition_type:
			"global_variable":
				if not check_query(query, environment_data):
					return false
			_:
				print("Tipo de condição desconhecido: ", condition_type)
				return false  # Falha se encontrar um tipo inválido
	return true  # Todas as condições foram atendidas

# Verifica as condições individuais no formato de query
func check_query(query, environment_data):
	for variable in query:
		var condition = query[variable].keys()[0]
		var value = query[variable][condition]
		var env_value = environment_data[variable]
		
		match condition:
			"gte":
				if env_value < value:
					return false
			"lte":
				if env_value > value:
					return false
			"eq":
				if env_value != value:
					return false
			_:
				print("Operação desconhecida: ", condition)
				return false
	return true
