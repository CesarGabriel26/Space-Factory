extends Panel

var item_name = ""

func _load(_name : String, _quantity : int):
	item_name = _name
	$Texture_react.texture = load(MainGlobal.item_sprite_path % _name)
	$Label.text = str(_quantity)
