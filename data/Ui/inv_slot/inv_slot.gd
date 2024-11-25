extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label

func _load_item(item_name : String, quantity : int):
	label.text = str(quantity)
	texture_rect.texture = load("res://resources/images/items/%s.png" % item_name)
	pass
