extends Node

signal setBuild

const item_sprite_path = "res://src/img/items/%s.png"
const machines_tier_color = {
	0.0: Color.YELLOW,
	1.0: Color.DARK_RED,
	2.0: Color.DARK_BLUE,
	3.0: Color("#622461"),
	"input" : Color.GREEN
}
const conveyor_speed = [
	0.875,
	1.75,
	2.625,
	3.5
]

var map_tiles = {}

var Building = "vacuum_tube"
var BuildingMode = false
var Builds_Node = null
var Items_Noode = null


func _ready():
	pass

func _process(delta):
	pass
