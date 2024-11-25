extends baseBlock


# Called when the node enters the scene tree for the first time.
func _ready():
	_load()
	$InvPreview/invController._update(data.map_pos)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
