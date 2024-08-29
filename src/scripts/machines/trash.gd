extends BaseMachine


func _ready():
	pass

func _process(delta):
	update()
	
	
	for i in Outinventory:
		Outinventory.erase(i)
	
	pass
