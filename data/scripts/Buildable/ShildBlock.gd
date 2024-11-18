extends baseBlock

@onready var sprite = $Sprite
@export var exploded = false

func _ready():
	sprite.region_rect = Rect2(Vector2(data['texture_cords']["x"], data['texture_cords']["y"]) * Constants.SPRITE_SIZE_32, Vector2(32,32))
	_load()
	pass

func _process(delta):
	if exploded:
		receiveDemage(.5)
	pass
