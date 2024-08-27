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
	update_tick()
	
	$CPUParticles2D.emitting = (inventory.size() > 0)
	
	pass

func tick():
	if inventory.has(0) and Outinventory.size() < 1:
		var results = processar_minerio(get_and_remove_item_from_last_slot(inventory))
		
		add_item_to_especific_slot(0, results[0], 1)
		if results.has(1):
			add_item_to_especific_slot(1, results[1], 1)

func processar_minerio(minerio):
	for recipe in recipes:
		if minerio in recipe["require"]:
			var resultado = [recipe["result"]]
			# Calcular chance de gerar escória
			if randf() < recipe["escoria"]:
				resultado.append("escoria")
			return resultado
	return {"erro": "Minerio não encontrado na receita"}

