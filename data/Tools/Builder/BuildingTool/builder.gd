extends Area2D

var data = {}

func _ready():
	await get_tree().process_frame
	_load_build("shild_block")

func _process(delta):
	global_position = get_parent()._map_pos_to_word_pos(get_parent()._word_pos_to_map_pos(get_global_mouse_position()))
	
	if !(get_overlapping_bodies().size() > 0):
		if Input.is_action_pressed("MouseL"):
			_build()
	
	$OverlayColor.visible = (get_overlapping_bodies().size() > 0)
	

func _load_build(_name : String = ""):
	if _name != "":
		data = JsonManager.get_on_json_by_keys(
			"res://resources/data/json/blockData.json", 
			[
				_name
			]
		)
	
		if !data.is_empty() and data["texture_file"]:
			$Sprite.texture = load(data["texture_file"])

func _build():
	if GlobalData.WorldTiles.has(get_parent()._word_pos_to_map_pos(global_position)):
		return
	else:
		if data.has_inventory.input:
			data['input_inv'] = {}
		if data.has_inventory.output:
			data['output_inv'] = {}
		if data.has_inventory.fluid_input:
			data['fluid_input_inv'] = [[]] # o input de fluido só aceita um tipo de fluido por isso o tamanho maximo é 1
		if data.has_inventory.fluid_output:
			data['fluid_output_inv'] = [[]]  # o output de fluido só aceita um tipo de fluido por isso o tamanho maximo é 1
		
		GlobalData.WorldTiles[get_parent()._word_pos_to_map_pos(global_position)] = data
	
	var prop = data.prop_scene
	if FileAccess.file_exists(prop):
		var BuildingSpot = load("res://data/Tools/Builder/BuildingSpot/BuildingSpot.tscn")
		var BuildingSpot_instance = BuildingSpot.instantiate()
		var target_node = get_parent().get_node("Blocks")
		
		BuildingSpot_instance.global_position = global_position
		BuildingSpot_instance.toBuild = prop
		BuildingSpot_instance.data = data
		BuildingSpot_instance.get_node("Panel").position = $Panel.position
		BuildingSpot_instance.get_node("Panel").size = $Panel.size
		
		target_node.add_child(BuildingSpot_instance)
		
	else:
		printerr("Arquivo %s Não Existe na pasta" % prop)
