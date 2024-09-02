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
	3.5,
]

const pollution_values = [
	5.0,  # Poluição por segundo para tier 1
	10.0, # Poluição por segundo para tier 2
	20.0, # Poluição por segundo para tier 3
	30.0  # Poluição por segundo para tier 4
]

var map_tiles = {}
var BuildingMode = false
var Builds_Node = null
var Items_Noode = null
var pollution_level = 0.0

var recipes = {}


func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("deb"):
		BuildingMode = !BuildingMode
	
	pass

func calculate_pollution():
	var poluentes = get_tree().get_nodes_in_group("poluentes")
	
	for poluente : BaseMachine in poluentes:
		if poluente.active:
			pollution_level += poluente.get_pollution_value()
