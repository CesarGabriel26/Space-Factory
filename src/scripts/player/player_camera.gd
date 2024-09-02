extends Camera2D

@export_category("Properties")
@export var zoom_level = .5
@export var speed = 5

var MouseIsInteractingWithUIElement = false

func _ready():
	SignalManager.MouseInteractingWithUIElement.connect(MouseInteractingWithUIElement)

func _physics_process(delta):
	var input = Input.get_vector("left","right","up","down")
	global_position += input * speed

func _input(event):
	if event.is_action_pressed("scroll down") and !MouseIsInteractingWithUIElement:
		if zoom > Vector2(.5,.5):
			zoom -= Vector2(.5,.5)
	elif event.is_action_pressed("scroll up") and !MouseIsInteractingWithUIElement:
		if zoom < Vector2(9,9):
			zoom += Vector2(.5,.5)

func MouseInteractingWithUIElement(Interactiong : bool):
	MouseIsInteractingWithUIElement = Interactiong
	pass
