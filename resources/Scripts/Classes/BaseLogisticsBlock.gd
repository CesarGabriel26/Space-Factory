extends BaseInventoryBlock
class_name BaseLogisticsChest

@export var inputPanel: Panel = null
@export var placeHolderTexture: TextureRect = null

func _ready() -> void:
	if blockData.get("is_preview") : return
	blockData['request_item'] = ""
	blockData['last_requested_item'] = ""
	inputPanel.gui_input.connect(gui_input)

func gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and ! Signals.building:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Signals.emit_signal("show_inv_window", self, 'InfiniteChest')

func _update_place_holder():
	if blockData['last_requested_item'] != blockData['request_item']:
		placeHolderTexture.texture = load("res://assets/images/items/" + blockData['request_item'] + ".png")
		blockData['last_requested_item'] = blockData['request_item']
