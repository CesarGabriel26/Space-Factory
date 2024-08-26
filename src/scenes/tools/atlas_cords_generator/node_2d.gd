@tool
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for y in 4:
		for x in 8:
			var label : Label = Label.new()
			label.set("theme_override_colors/font_color", Color("2f56ff"))
			label.set("theme_override_font_sizes/font_size", 12)
			label.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			add_child(label)
			label.text = "(" + str(x) + "," + str(y) + ")"
			label.global_position = Vector2(32 * x,32 * y)
	
	pass # Replace with function body.
