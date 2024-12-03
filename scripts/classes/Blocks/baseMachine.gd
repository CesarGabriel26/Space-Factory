extends baseBlock
class_name baseMachine

func _setup():
	var timer = Timer.new()
	timer.wait_time = data.delay
	timer.name = "DelayTimer"
	timer.one_shot = true
	add_child(timer)
	timer.start()

func _update():
	var timer : Timer = get_node("DelayTimer")
	var time = timer.get_time_left()
	if time <= 0:
		timer.start()
		call_deferred("_tick")
	
	
