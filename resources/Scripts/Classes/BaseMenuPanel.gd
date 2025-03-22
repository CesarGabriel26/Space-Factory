extends Control
class_name BaseMenuPanel

@export var close_button: Button = null

var WindowNameToReturn = ""

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_close)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			_close()

func _close():
	Signals.emit_signal('hide_inv_window', WindowNameToReturn)
