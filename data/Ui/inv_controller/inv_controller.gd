extends Node2D

const INV_SLOT = preload("res://data/Ui/inv_slot/inv_slot.tscn")

@onready var in_inv = $"invController/In-inv"
@onready var out_inv = $"invController/Out-inv"

func _update(map_pos : Vector2):
	var block_data = MapDataManager.WorldTiles[map_pos]
	
	in_inv.visible = block_data.has('input_inv')
	if block_data.has('input_inv'):
		var input_inv = block_data['input_inv']
		for slot_index in input_inv:
			var current_slot = (in_inv.get_child_count() > slot_index)
			
			if !current_slot:
				var slot = INV_SLOT.instantiate()
				slot.name = str(slot_index)
				in_inv.add_child(slot)
			
			current_slot = in_inv.get_child(slot_index)
			
			var item = input_inv[slot_index]
			current_slot._load_item(item[0], item[1])
	
	out_inv.visible = block_data.has('output_inv')
	if block_data.has('output_inv'):
		var output_inv = block_data['output_inv']
		for slot_index in output_inv:
			var current_slot = (out_inv.get_child_count() > slot_index)
			
			if !current_slot:
				var slot = INV_SLOT.instantiate()
				slot.name = str(slot_index)
				out_inv.add_child(slot)
			
			current_slot = out_inv.get_child(slot_index)
			
			var item = output_inv[slot_index]
			current_slot._load_item(item[0], item[1])
	pass
