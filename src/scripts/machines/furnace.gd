extends BaseMachine

func _ready():
	MouseDetectionPanel = $Panel
	inventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	recipes = [
		{
			"require": ["minerio_de_cobre"],
			"result": "barra_de_cobre",
			"escoria": 0.1
		},
		{
			"require": ["minerio_de_ferro"],
			"result": "barra_de_ferro",
			"escoria": 0.15
		},
		{
			"require": ["minerio_de_ouro"],
			"result": "barra_de_ouro",
			"escoria": 0.05
		},
		{
			"require": ["minerio_de_zinco"],
			"result": "barra_de_zinco",
			"escoria": 0.2
		}
	]
	
	_setup()
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	pass

func tick():
	if inventory.has(0):
		var results = processar_minerio(get_item_from_first_slot())
		for i in results.size():
			var invIndex = i + 1
			if not inventory.has(invIndex):
				inventory[invIndex] = [results[i], 1]
			else:
				add_item_to_inventory(results[i], 1)
			

func processar_minerio(minerio):
	for recipe in recipes:
		if minerio in recipe["require"]:
			var resultado = [recipe["result"]]
			# Calcular chance de gerar escória
			if randf() < recipe["escoria"]:
				resultado.append("escoria")
			return resultado
	return {"erro": "Minerio não encontrado na receita"}

