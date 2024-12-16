extends Node2D

var item_name = ""

func _ready():
	$Sprite2D.texture = load("res://resources/images/items/%s.png" % item_name)
