extends baseBlock
class_name buildingArea

var toBuild : String = ""
var build_progress = 0.0
var shader = ShaderMaterial.new()

func _ready():
	life = 1
	$CollisionShape2D.shape.size = $Panel.size
	DroneManager.builds_for_drones.append([self, false])
	
	shader.shader = load("res://resources/Shaders/BuildingSpot.gdshader")
	
	$Sprite.material = shader
	
	$Sprite.texture = load(data["texture_file"])
	$Sprite/Sprite2.texture = load(data["texture_file"])
	
	$Sprite.region_rect = Rect2(Vector2(data['texture_cords']["x"], data['texture_cords']["y"]) * Constants.SPRITE_SIZE_32, Vector2(32,32))
	$Sprite/Sprite2.region_rect = Rect2(Vector2(data['texture_cords']["x"], data['texture_cords']["y"]) * Constants.SPRITE_SIZE_32, Vector2(32,32))
	
	shader.set("shader_parameter/build_progress", .5)

func _update():
	shader.set("shader_parameter/build_progress", build_progress)

func _done():
	DroneManager.builds_for_drones.erase([self, true])
	
	var propPacked : PackedScene = load(toBuild)
	var propInstance = propPacked.instantiate()
	propInstance.data = data
	propInstance.global_position = global_position
	get_parent().add_child(propInstance)
	queue_free()
