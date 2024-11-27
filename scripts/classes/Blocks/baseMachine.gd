extends baseBlock
class_name baseMachine

func _setup():
	var timer = Timer.new()
	timer.wait_time = data.delay
	timer.name = "DelayTimer"
	add_child(timer)

func _tick():
	var timer : Timer = get_node("DelayTimer")
	var time = timer.get_time_left()
	if time <= 0:
		timer.start()
	
	print(time)
	
