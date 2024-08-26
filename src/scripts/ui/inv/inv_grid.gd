extends GridContainer
class_name InventoryGrid

@onready var item = preload("res://src/scenes/UI/inv/inv_item.tscn")

func add_item(id : int, _name : String, _quantity : int):
	var i = item.instantiate()
	i._load(_name,_quantity)
	i.name = str(id)
	add_child(i)

func update_item_quantity(id : int, _quantity : int):
	var child = get_child(id)
	child._load(child.item_name, _quantity)

func remove_item(id : int):
	var child = get_child(id)
	if child :
		child.queue_free()

func has_slot(id : int):
	var child_count = get_child_count()
	if child_count > id :
		return true
	return false
