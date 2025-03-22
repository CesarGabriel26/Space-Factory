extends BaseItemTransferBlock
class_name Conveyor

func _ready() -> void:
	MapDataManager.tick.connect(_tick)

func _tick():
	move_item_to_target()
