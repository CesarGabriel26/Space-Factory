extends BaseInventoryBlock

func _ready() -> void:
	MapDataManager.tick.connect(_tick)

func _tick():
	open_inventory()
	inventory.clear()
	save_inventory()
	close_inventory()
	pass
