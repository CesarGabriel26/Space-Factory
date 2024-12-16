extends Node

var WorldTiles = {}
var WorldData = {}

func _get_nearby_blocks(initial_pos: Vector2):
	const check_pos = [
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.RIGHT
	]
	var blocks = []
	
	for pos in check_pos:
		var target = initial_pos + pos
		
		if WorldTiles.has(target):
			blocks.append(WorldTiles[target])
		else:
			blocks.append(null)
		
	return blocks
	pass
