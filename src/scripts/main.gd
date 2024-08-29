extends Node2D

@export var Tile_Map : TileMap
@export var Builder : Node2D


func _ready():
	MainGlobal.Builds_Node = $props/machines
	MainGlobal.Items_Noode = $props/items
	pass

func _process(delta):
	Builder.global_position = Tile_Map.map_to_local(Tile_Map.local_to_map(get_global_mouse_position()))
	Builder.tileMap = Tile_Map
	$CanvasLayer/Label.text = str(MainGlobal.pollution_level)
	pass
