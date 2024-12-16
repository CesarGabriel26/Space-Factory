extends Panel

@onready var close: Button = $CenterContainer/Container/Header/close
@onready var tab_container: TabContainer = $CenterContainer/Container/Body/TabContainer
@onready var tab_buttons: VBoxContainer = $CenterContainer/Container/Body/TabButtons/TabButtons/ScrollContainer/TabButtons

var btn_teste_group : ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close.pressed.connect(_close)
	btn_teste_group = ButtonGroup.new()
	_load_blocks()
	pass # Replace with function body.


func _close():
	visible = false
	pass

func _create_tab(_name : String, index: int):
	var button : Button = Button.new()
	var tabBar : TabBar = TabBar.new()
	var marginContainer : MarginContainer = MarginContainer.new()
	var flowContainer : FlowContainer = FlowContainer.new()
	
	button.name = _name
	button.custom_minimum_size = Vector2(0, 32)
	button.text = _name.capitalize()
	button.toggle_mode = true
	button.button_group = btn_teste_group
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(_change_tab.bind(index))
	tab_buttons.add_child(button)
	
	tabBar.name = _name
	tabBar.add_child(marginContainer)
	
	marginContainer.name = _name
	marginContainer.set_anchors_preset(Control.PRESET_FULL_RECT)
	marginContainer.set("theme_override_constants/margin_left", 10)
	marginContainer.set("theme_override_constants/margin_top", 10)
	marginContainer.set("theme_override_constants/margin_right", 10)
	marginContainer.set("theme_override_constants/margin_bottom", 10)
	marginContainer.add_child(flowContainer)
	
	flowContainer.name = _name
	
	tab_container.add_child(tabBar)
	
	return flowContainer

func _load_sprites(btn : Button, loaded_textures : Dictionary):
	var textures = loaded_textures.textures
	
	TextureManager._add_sprites(textures, false, [], btn, null, true)

func _create_button(block : String, data : Dictionary):
	var button : Button = Button.new()
	button.name = block
	button.custom_minimum_size = Vector2(64,64)
	button.pressed.connect(_set_building.bind(block))
	
	var loaded_textures = TextureManager._get_texture(data.texture)
	_load_sprites(button, loaded_textures)
	
	return button

func _load_blocks():
	var blocks = JsonManager.read_from_json_file("res://resources/data/json/blockData.json")
	
	var tabs_created = {
		
	}
	
	var i = 0
	
	for block in blocks:
		var data = blocks[block]
		
		if tabs_created.has(data.menu):
			var container : FlowContainer = tabs_created[data.menu]
			container.add_child(
				_create_button(block, data)
			)
		else:
			var container : FlowContainer = _create_tab(data.menu, i)
			i += 1
			tabs_created[data.menu] = container
			container.add_child(
				_create_button(block, data)
			)
	pass

func _set_building(building :  String):
	DroneManager.emit_signal("load_new_build", building)
	_close()
	pass

func _change_tab(index : int):
	tab_container.current_tab = index
	pass
