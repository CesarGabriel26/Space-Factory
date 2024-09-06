extends Control

@export var tab_container : TabContainer
@export var button_container : GridContainer

func _ready():
	if tab_container and button_container:
		var data = JsonManager.LerJson("res://src/data/maquinas.json")
		load_items( create_tab_buttons(data), data )
	pass

func _process(delta):
	pass

func load_items(menu_tabs, data):
	for machine in data:
		var button = Button.new()
		var menu : GridContainer = menu_tabs[data[machine]["menu"]]
		
		var icon_data = data[machine]["menu_icon"]
		if typeof(icon_data) == TYPE_DICTIONARY:
			var atlas = AtlasTexture.new()
			atlas.atlas = load("res://src/img/sheets/icons_sheet.png")
			
			var MachineSize = Vector2(icon_data["size"][0], icon_data["size"][1])
			var cords = Vector2 (icon_data["cords"][0],icon_data["cords"][1]) * MachineSize
			
			atlas.region = Rect2(
				cords,
				MachineSize
			)
			
			button.icon = atlas
		else:
			button.icon = load(data[machine]["menu_icon"])
		
		button.name = machine
		button.expand_icon = true
		button.custom_minimum_size = Vector2(48,48)
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
		
		grid.columns = 4
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
		var icon : String = ""
		
		if FileAccess.file_exists("res://src/img/Ui/icons/%s.png" % str(tab.name)):
			icon = "res://src/img/Ui/icons/%s.png" % str(tab.name)
		
		menu_tabs[tab.name] = tab.get_node("ScrollContainer/container")
		button_container.add_child(create_button(str(i), str(tab.name).to_upper()[0], icon))
	
	return menu_tabs

func create_button(bName : String = "", text : String = "", icon : String = ""):
	var button = Button.new()
	
	button.name = bName
	button.custom_minimum_size = Vector2(48,48)
	button.pressed.connect(select_tab.bind(bName))
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.expand_icon = true
	
	if icon != "":
		button.icon = load(icon)
	else:
		button.text = text
	
	return button

func select_tab(tabStringId : String):
	tab_container.current_tab = int(tabStringId)
	MainGlobal.BuildingMode = true
	SignalManager.emit_signal("MouseEnteredUI", true)
	pass

func select_build(build : String):
	SignalManager.emit_signal("BuildSelected", build)
	MainGlobal.BuildingMode = true
	pass

func _on_mouse_entered():
	SignalManager.emit_signal("MouseEnteredUI", true)

func _on_mouse_exited():
	SignalManager.emit_signal("MouseEnteredUI", false)
