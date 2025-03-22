extends Node

func _ready() -> void:
	#MapDataManager.tick.connect(_update)
	pass

func _update():
	var nodesLu := get_tree().get_nodes_in_group('item_LU')
	nodesLu = nodesLu.filter(func(node): return (node.blockData.slots.size() < node.ItensSprites.size()))
	
	for node : ItemLu in nodesLu:
		if node.blockData.action_type == 'unload':
			pass
	
	var nodes := get_tree().get_nodes_in_group('item_move')
	nodes = nodes.filter(func(node): return node.blockData.slots.size() > 0)
	for node : BaseItemTransferBlock in nodes:
		pass
