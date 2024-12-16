extends Control

const clouds = preload("res://resources/models/Planet/clouds.tres")
const speed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	clouds.shader.set("shader_parameter/speed", -speed * 2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node/SubViewport/Planet.rotation_degrees.y += speed
	pass
