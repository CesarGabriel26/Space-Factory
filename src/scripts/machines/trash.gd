extends BaseMachine


func _ready():
	ItemInputsNode = $Inputs
	pass

func _process(delta):
	if preview : return
	update()
	
	for i in Outinventory:
		Outinventory.erase(i)
	
	#take_damage(.1)
	
	#await get_tree().create_timer(.5).timeout
	
	pass
