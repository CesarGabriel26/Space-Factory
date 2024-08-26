extends Node2D
class_name ItemBox



var item_name = "minerio_de_cobre"

func _ready():
	$img.texture = load(MainGlobal.item_sprite_path % item_name)

func _load_item(_name : String):
	item_name = _name
	$img.texture = load(MainGlobal.item_sprite_path % item_name)
	
	
