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

func send_block_data(send : bool):
	var send_data = {
		"name" : data["name"],
		"life" : life,
		"life_max" : max_life,
	}
	
	if send:
		SignalManager.emit_signal("MouseHoveringBlock", send_data)
	else:
		SignalManager.emit_signal("MouseHoveringBlock", {})
	pass
