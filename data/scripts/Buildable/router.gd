extends baseBlock


# Called when the node enters the scene tree for the first time.
func _ready():
	_load()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_item_in(delta)
	_move_items_out(true)
	
	pass
