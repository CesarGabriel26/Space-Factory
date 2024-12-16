@tool
extends StaticBody3D

@export var text: String = "" : set = _set_text
@export var function: String = ""
@export var color: Color = Color("#73959b") : set = _set_color

func _ready():
	var material : StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	$Node3D/MeshInstance3D.set_surface_override_material(0, material)

func _set_text(t):
	text = t
	name = text
	$Node3D/Label3D.text = text

func _set_color(c):
	color = c
	var material : StandardMaterial3D = $Node3D/MeshInstance3D.get_surface_override_material(0)
	material.albedo_color = color
	$Node3D/MeshInstance3D.set_surface_override_material(0, material)
