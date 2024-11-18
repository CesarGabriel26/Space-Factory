extends RayCast2D
class_name laser

@onready var line2d = $Line2D
var ligado := false : set = set_ligado
var manual_target_position : Vector2 = Vector2.ZERO
var color : Color = Color.ORANGE

func _ready():
	line2d.points[1] = Vector2.ZERO

func set_ligado(v):
	ligado = v

func _physics_process(delta):
	var cast_point : Vector2 = Vector2.ZERO
	force_raycast_update()
	
	line2d.default_color = color
	$"1".emitting = ligado
	$"1".color = color
	$"0".emitting = ligado
	$"0".color = color
	
	if ligado:
		aparece()
	else:
		desaparece()
	
	if manual_target_position != Vector2.ZERO:
		cast_point = to_local(manual_target_position)
	elif is_colliding():
		cast_point = to_local(get_collision_point())
		cast_point.y = cast_point.y - 16
	
	if cast_point != Vector2.ZERO:
		line2d.points[1] = cast_point
		$"1".position = cast_point

func aparece():
	line2d.width = lerpf(line2d.width, 10, .2)

func desaparece():
	line2d.width = lerpf(line2d.width, 0, .2)
