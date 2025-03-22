extends BaseMenuPanel

const ITEM_SELECT = preload("res://resources/Scenes/ui/logistics-container/ItemSelect/item_select.tscn")
const STYLE_CINZA = preload("res://resources/Styles/Container/Cinza.tres")
const STYLE_CINZA_SELECT = preload("res://resources/Styles/Container/CinzaSelect.tres")

@onready var v_box_container: VBoxContainer = $ItemSelectList/ScrollContainer/VBoxContainer
@onready var texture_rect: TextureRect = $ItemSelectSlot/TextureRect
@onready var edit: LineEdit = $ItemSelectList/searchBar/edit

var NodeToModify : BaseLogisticsChest = null

func _ready() -> void:
	super._ready()
	edit.text_changed.connect(_search)
	_populate_item_list()

func _populate_item_list():
	var options = DataManager.ItensData.keys()
	options.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	for item in options:
		var itemSelect = ITEM_SELECT.instantiate()
		itemSelect._setup(item)
		itemSelect.pressed.connect(_select_item)
		itemSelect.name = item
		v_box_container.add_child(itemSelect)

func _update():
	_apply_styles(NodeToModify.blockData.request_item)

func _select_item(item_name):
	texture_rect.texture = load("res://assets/images/items/%s.png" % item_name)
	_apply_styles(item_name)
	NodeToModify.blockData.request_item = item_name

func _apply_styles(target_name: String):
	var match_ = false
	
	for panel: Panel in v_box_container.get_children():
		var style = STYLE_CINZA_SELECT if panel.name == target_name else STYLE_CINZA
		panel.set("theme_override_styles/panel", style)
		
		if panel.name == target_name and not match_:
			match_ = true
			texture_rect.texture = load("res://assets/images/items/%s.png" % panel.name)
		else:
			if not match_:
				texture_rect.texture = load("res://assets/images/ui/Icons/Close.png")

func _search(text: String):
	for panel: Panel in v_box_container.get_children():
		panel.visible = text in panel.name if text != "" else true
