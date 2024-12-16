@tool
extends Node3D

@export var spacing: float = .12
@export var update: bool = false : set = _set_update

func _set_update(v):
	update = false
	organize_children()  # Organiza os filhos ao iniciar a cena.

func organize_children():
	var current_position: Vector3 = Vector3.ZERO
	for child : StaticBody3D in get_children():
		child.position = current_position
		current_position += Vector3(0, spacing, 0)  # Ajuste no eixo X (pode trocar para Y ou Z se preferir).
