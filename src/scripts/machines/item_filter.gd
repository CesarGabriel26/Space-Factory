extends BaseMachine

@onready var item_selection = $inventory/ItemSelection

func _ready():
	MouseDetectionPanel = $Panel
	outInventory_node = $inventory/inv_grid
	ItemOutputsNode = $Outputs
	ItemInputsNode = $Inputs
	BuildingModeInAndOutPreview = $"model/Inputs-outputs"
	
	if !preview:
		MouseDetectionPanel.connect("gui_input", handle_input)
		item_selection._load()
		item_selection.connect("FilterChanged", set_filters)
	
	_setup()
	pass

func _process(delta):
	update()
	
	pass

func handle_input(event: InputEvent):
	if event is InputEventMouseButton and  event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			item_selection.visible = !item_selection.visible
			SignalManager.emit_signal("MouseInteractingWithUIElement", item_selection.visible)
		
	pass

func set_filters(filters: Dictionary):
	var outputFilter = filters.duplicate()
	
	for key in outputFilter.keys():
		if outputFilter[key] == "null":
			outputFilter.erase(key)

	ExpectedItemsOutput = outputFilter

func send_block_data(send : bool):
	var send_data = {
		"name" : data["name"],
		"life" : life,
		"life_max" : max_life,
	}
	
	if send:
		SignalManager.emit_signal("MouseHoveringBlock", send_data)
	else:
		SignalManager.emit_signal("MouseHoveringBlock", {})
	pass
