extends Control

signal FilterChanged

@export var TabButtonGroup : ButtonGroup = null
@export var ItemButtonGroup : ButtonGroup = null
@onready var item_selection_grid = $CenterContainer/ScrollContainer/item_selection_grid


var current_filter = 1

var Filters = {
	1 : "null",
	2 : "null",
	3 : "null"
}

func _load():
	var items : Dictionary = JsonManager.LerJson("res://src/data/items.json")
	var item_names : Array = items.keys()
	
	item_names.insert(0, "null")
	
	for item in item_names:
		var btn = Button.new()
		
		btn.icon = load("res://src/img/items/%s.png" % item)
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.custom_minimum_size = Vector2(16,16)
		btn.set("theme_override_constants/icon_max_width", 12)
		
		for filter in Filters:
			if Filters[filter] == item:
				btn.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
				btn.set("theme_override_styles/hover", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
			else:
				btn.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_normal.tres"))
				btn.set("theme_override_styles/hover", StyleBoxEmpty.new())
		
		btn.set("theme_override_styles/disabled", load("res://src/styles/buttons/item_selection/item_selection_normal.tres"))
		btn.set("theme_override_styles/pressed", load("res://src/styles/buttons/item_selection/item_selection_Pressed.tres"))
		btn.set("theme_override_styles/focus", StyleBoxEmpty.new())
		
		btn.button_group = ItemButtonGroup
		
		btn.name = item
		
		item_selection_grid.add_child(btn)
	
	var TabBtns = TabButtonGroup.get_buttons()
	for btn : Button in TabBtns:
		btn.pressed.connect(TabButton_pressed.bind(btn))
		if int(str(btn.name)) == current_filter:
			btn.get_parent().set("theme_override_styles/panel", load("res://src/styles/itemFilter/item_filter_tab%s_select.tres" % btn.name))
		
	
	var ItemBtns = ItemButtonGroup.get_buttons()
	for btn : Button in ItemBtns:
		btn.pressed.connect(ItemButton_pressed.bind(btn))
	pass

func TabButton_pressed(button : Button):
	if !visible: return
	
	var TabBtns = TabButtonGroup.get_buttons()
	for btn : Button in TabBtns:
		var style = null
		
		if btn.name == button.name:
			btn.grab_focus()
			style = load("res://src/styles/itemFilter/item_filter_tab%s_select.tres" % button.name)
			current_filter = int(str(button.name))
		else:
			style = load("res://src/styles/itemFilter/item_filter_tab%s.tres" % btn.name)
		
		btn.get_parent().set("theme_override_styles/panel", style)
	
	var ItemBtns = ItemButtonGroup.get_buttons()
	for btn in ItemBtns:
		if Filters[int(str(button.name))] == btn.name:
			btn.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
			btn.set("theme_override_styles/hover", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
		else:
			btn.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_normal.tres"))
			btn.set("theme_override_styles/hover", StyleBoxEmpty.new())

func ItemButton_pressed(button : Button):
	if !visible: return
	
	var ItemBtns = ItemButtonGroup.get_buttons()
	for btn : Button in ItemBtns:
		btn.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_normal.tres"))
		btn.set("theme_override_styles/hover", StyleBoxEmpty.new())
	
	button.set("theme_override_styles/normal", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
	button.set("theme_override_styles/hover", load("res://src/styles/buttons/item_selection/item_selection_Focus.tres"))
	
	Filters[current_filter] = str(button.name)
	emit_signal("FilterChanged", Filters)
	pass
