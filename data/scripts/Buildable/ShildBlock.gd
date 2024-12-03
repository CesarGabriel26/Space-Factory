extends baseBlock

@export var exploded = false

func _ready(): 
	_load()
	pass

func _process(delta):
	if exploded:
		receiveDemage(.5)
	pass
