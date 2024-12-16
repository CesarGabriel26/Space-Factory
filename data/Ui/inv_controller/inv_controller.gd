extends Node2D
class_name InvController

const INV_SLOT = preload("res://data/Ui/inv_slot/inv_slot.tscn")

@onready var in_inv = $"invController/In-inv"
@onready var out_inv = $"invController/Out-inv"

func _update(map_pos : Vector2):
	var block_data = MapDataManager.WorldTiles[map_pos]
	
	in_inv.visible = block_data.has('input_inv')
	if block_data.has('input_inv'):
		var input_inv = block_data['input_inv']
		
		if input_inv.size() < 1:
			for c in in_inv.get_children():
				c.queue_free()
			
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
		
		if output_inv.size() < 1:
			for c in out_inv.get_children():
				c.queue_free()
		
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
