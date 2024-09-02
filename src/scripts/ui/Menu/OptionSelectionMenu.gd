extends Control

@onready var tab_container = $BuildMenu/MarginContainer/TabContainer
@onready var button_container = $MarginContainer/OptionSelectionMenu/Buttons/CenterContainer/ButtonContainer
@onready var build_menu = $BuildMenu

func _ready():
	var data = JsonManager.LerJson("res://src/data/maquinas.json")
	load_items( create_tab_buttons(data), data )
	pass

func _process(delta):
	pass

func load_items(menu_tabs, data):
	for machine in data:
		var button = Button.new()
		var menu : GridContainer = menu_tabs[data[machine]["menu"]]
		
		button.name = machine
		button.icon = load(data[machine]["menu_icon"])
		button.expand_icon = true
		button.custom_minimum_size = Vector2(64,64)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.pressed.connect(select_build.bind(button.name))
		
		menu.add_child(button)

func create_tab_buttons(data):
	var menus_encontrados = []
	for machine in data:
		var menu_name = data[machine]["menu"]
		var menu = TabBar.new()
		var scrol = ScrollContainer.new()
		var grid = GridContainer.new()
		
		if menus_encontrados.has(menu_name):
			continue
		else:
			menus_encontrados.append(menu_name)
		
		grid.columns = 13
		grid.set("theme_override_constants/h_separation",5)
		grid.set("theme_override_constants/v_separation",5)
		
		grid.name = "container"
		scrol.name = "ScrollContainer"
		menu.name = menu_name
		
		scrol.layout_mode = 1 # LAYOUT_MODE_ANCHORS <- por algum motivo essa contante ñ existe nessa verção da godot 4.2.2
		scrol.anchors_preset = PRESET_FULL_RECT
		
		scrol.add_child(grid)
		menu.add_child(scrol)
		
		grid.mouse_filter = Control.MOUSE_FILTER_PASS
		scrol.mouse_filter = Control.MOUSE_FILTER_PASS
		menu.mouse_filter = Control.MOUSE_FILTER_PASS
		
		tab_container.add_child(menu)
	
	var tabs = tab_container.get_children()
	
	var menu_tabs = {}
	for i in tabs.size():
		var tab = tabs[i]
		
		menu_tabs[tab.name] = tab.get_node("ScrollContainer/container")
		button_container.add_child(create_button(str(i), str(tab.name).to_upper()[0]))
	
	return menu_tabs

func create_button(bName : String = "", text : String = "", icon : String = ""):
	var button = Button.new()
	
	button.name = bName
	button.custom_minimum_size = Vector2(64,64)
	button.pressed.connect(select_tab.bind(bName))
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if icon != "":
		button.icon = load(icon)
	else:
		button.text = text
	
	return button

func select_tab(tabStringId : String):
	tab_container.current_tab = int(tabStringId)
	MainGlobal.BuildingMode = true
	build_menu.visible = true
	SignalManager.emit_signal("MouseEnteredUI", true)
	pass

func select_build(build : String):
	build_menu.visible = false
	SignalManager.emit_signal("MouseEnteredUI", false)
	SignalManager.emit_signal("BuildSelected", build)
	MainGlobal.BuildingMode = true
	pass

func _on_mouse_entered():
	SignalManager.emit_signal("MouseEnteredUI", true)

func _on_mouse_exited():
	SignalManager.emit_signal("MouseEnteredUI", false)
