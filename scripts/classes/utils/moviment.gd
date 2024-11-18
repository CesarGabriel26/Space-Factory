extends Node

"""
var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
"""

func _move(target : CharacterBody2D, direction : Vector2 = Vector2.ZERO, speed : float = 300.0):
	if direction:
		target.velocity = direction * speed
	else:
		target.velocity.x = move_toward(target.velocity.x, 0, speed)
		target.velocity.y = move_toward(target.velocity.y, 0, speed)
	
	target.move_and_slide()
