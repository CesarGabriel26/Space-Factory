extends Control

@onready var rich_text_label = $RichTextLabel

# List of strings to display, each string can have its own speed.
var text_lines = [
	{"text": "Making Modular BIOS V 48.1.6AF, An IM Dubleyou Ally\n", "speed": 0.2},
	{"text": "\nVersion 52.8.D874\n", "speed": 0.2},
	{"text": "\nPENTIUM-XXMM CPU at 166 Ghz\n", "speed": 0.2},
	{"text": "\nMemory Test : 131072G OK\n", "speed": 0.3},
	{"text": "	Detecting HDD Primary Master				.	.	.	QUANTUM 270A				- OK\n", "speed": 0.1},
	{"text": "	Detecting HDD Primary Slave					.	.	.	TRANSDISK-T					- OK\n", "speed": 0.1},
	{"text": "	Detecting HDD Secondary Master			.	.	.	MULTIDISK UNIT				- OK\n", "speed": 0.1},
	{"text": "	Detecting HDD Secondary Slave				.	.	.	USB 4.2 PORT STATION	- OK\n", "speed": 0.1},
	{"text": "\nBooting Software Inc. 35 A.E\n", "speed": 0.4},
	{"text": "\n|----------------------------------------------------SOLAR STATION STARTUP CHECK--------------------------------------------------|\n", "speed": 0.3},
	{"text": "| SOLAR PANEL 1 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 2 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 3 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 4 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 5 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 6 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 7 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 8 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "| SOLAR PANEL 9 CHECK .	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	100% OK 		 |\n", "speed": 0.5},
	{"text": "\n|------------------------------------------------SOLAR STATION STARTUP SUCCESSFUL----------------------------------------------|\n", "speed": 0.4},
	{"text": "\nPress ENTER to enter Main Menu\n", "speed": 0.3},
	{"text": "03/13/58 - VW82C589VP-ZALA09BC-00", "speed": 0.2},
]

var current_line_index = 0
var current_char_index = 0
var typing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("down"):
		typing = true
	
	if typing:
		var line = text_lines[current_line_index]
		var text = line["text"]
		var speed = line["speed"]
		
		if current_char_index < text.length():
			rich_text_label.append_text(text.substr(current_char_index, 1))
			current_char_index += 1
			await get_tree().create_timer(speed).timeout
		else:
			current_char_index = 0
			current_line_index += 1
			
			if current_line_index >= text_lines.size():
				typing = false  # Stop typing when all lines are done
				return
