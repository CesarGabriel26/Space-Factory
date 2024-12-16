extends baseBlock


# Called when the node enters the scene tree for the first time.
func _ready():
	_load()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_item_in(delta)
	_move_items_out()
	
	var item = InventoryManager.get_item_from_last_slot(data.output_inv)
	if item and get_node("Items/item"):
		var tx = load("res://resources/images/items/%s.png" % item)
		$Items/item.texture = tx
	elif get_node("Items/item"):
		$Items/item.texture = null
	
	pass
