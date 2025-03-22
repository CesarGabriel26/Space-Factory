extends BaseBlock
class_name FluidTank

func _ready() -> void:
	if blockData.get('is_preview'): return
	MapDataManager.tick.connect(_tick)


func _tick():
	var alpha : float = blockData.fluid_amount / blockData.capacity
	ModelspritesNode.get_child(0).modulate = Color(0, 0.396, 1, alpha)

func withdraw(amount: float) -> float:
	var extracted = min(amount, blockData.fluid_amount)
	blockData.fluid_amount -= extracted
	return extracted

func insert(amount: float):
	blockData.fluid_amount = min(blockData.capacity, blockData.fluid_amount + amount)
