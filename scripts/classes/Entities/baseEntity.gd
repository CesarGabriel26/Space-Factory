extends Node2D
class_name baseEntity

@export_category("Stats")
@export var life: float = 0.0
@export var explosion_radius : float = 1.0

var selected = false

func receiveDemage(d : float):
	life -= d
	pass

func regenLife(r):
	life += r
	pass
