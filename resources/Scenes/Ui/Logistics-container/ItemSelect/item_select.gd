extends Panel

signal pressed

@export var texture_rect: TextureRect = null
@export var button: Button = null
@export var label: Label = null

var item_name

func _setup(item) -> void:
	item_name = item
	label.text = item
	texture_rect.texture = load("res://assets/textures/items/" + item + ".png")
	button.pressed.connect(_emit_pressed)

func _emit_pressed():
	emit_signal("pressed", item_name)
