extends BaseMenuPanel

@export var tab_container: TabContainer = null
@export var edit: LineEdit = null
@export var Search: VBoxContainer = null
@export var TabSelector : HBoxContainer = null

var tabs = {}

func _ready() -> void:
	edit.text_changed.connect(_search)
	
	# Criar aba de pesquisa
	tabs["Search"] = {
		"pagina": Search,
		"grupos": {}
	}

	# Criar os itens nas abas corretas
	for block in DataManager.BlocksData:
		_add_item_to_page(block, DataManager.BlocksData[block])
	_create_pages_buttons()

func _search(text: String) -> void:
	var pagina: VBoxContainer = tabs["Search"].pagina
	for grupo in pagina.get_children():
		var itens = grupo.get_children()
		# Mostrar apenas os itens que correspondem à busca
		var tem_item = false
		
		for item in itens:
			var item_text = item.name.to_lower()
			var _match = (text.to_lower() in item_text or text == "")
			item.visible = _match
			if _match:
				tem_item = true
		
			# Esconder grupos vazios
		grupo.visible = tem_item

func _create_pages_buttons():
	var pages = tabs.keys()
	for page in pages:
		var page_index = pages.find(page)
		
		var button := Button.new()
		button.custom_minimum_size = Vector2(80.0, 80.0)
		button.name = page
		button.text = page[0]
		TabSelector.add_child(button)
		button.pressed.connect(_tab_selector_button_pressed.bind(page_index))

func _create_page_if_not_exists(page_name: String) -> void:
	if tabs.has(page_name):
		return
	
	var page_panel := Panel.new()
	page_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_panel.name = page_name
	page_panel.set("theme_override_styles/panel", load("res://resources/Styles/Container/innerPanel.tres"))
	
	var page_margin := MarginContainer.new()
	page_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_margin.add_theme_constant_override("margin_left", 8)
	page_margin.add_theme_constant_override("margin_top", 8)
	page_margin.add_theme_constant_override("margin_right", 8)
	page_margin.add_theme_constant_override("margin_bottom", 8)
	
	var page_scroll := ScrollContainer.new()
	page_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var page_vertical_align := VBoxContainer.new()
	page_vertical_align.name = page_name
	
	page_scroll.add_child(page_vertical_align)
	page_margin.add_child(page_scroll)
	page_panel.add_child(page_margin)
	
	tab_container.add_child(page_panel)
	
	tabs[page_name] = {
		"pagina": page_vertical_align,
		"grupos": {}
	}

func _create_item_button(item_name: String, block_data: Dictionary) -> Button:
	var textures = LayeredTextureManager._load_model_texture(block_data)
	var button := Button.new()
	button.custom_minimum_size = Vector2(64, 64)
	button.name = item_name
	
	for texture in textures:
		var texture_rect := TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.texture = texture.atlas
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	
		# Aplicar propriedades
		for prop in texture.props:
			texture_rect.set(prop, texture.props[prop])
		
		button.add_child(texture_rect)
	button.pressed.connect(_button_pressed.bind(button.name))
	return button

func _create_group_if_not_exists(page_name: String, group_name: String) -> void:
	var page = tabs[page_name].pagina
	var grupos = tabs[page_name].grupos

	if grupos.has(group_name):
		return

	var group := HBoxContainer.new()
	group.name = group_name
	grupos[group_name] = group
	page.add_child(group)

	# Criar cópia do grupo na aba de pesquisa
	var search_group := group.duplicate()
	tabs["Search"].pagina.add_child(search_group)
	tabs["Search"].grupos[group_name] = search_group

func _add_item_to_group(item_name: String, block_data: Dictionary) -> void:
	var page_name = block_data.menu.tab
	var group_name = block_data.menu.group
	
	_create_group_if_not_exists(page_name, group_name)
	
	var grupo = tabs[page_name].grupos[group_name]
	var search_grupo = tabs["Search"].grupos[group_name]
	
	var item_button = _create_item_button(item_name, block_data)
	var search_grupo_item_button = _create_item_button(item_name, block_data)
	
	grupo.add_child(item_button)
	search_grupo.add_child(search_grupo_item_button)

func _add_item_to_page(item_name: String, block_data: Dictionary) -> void:
	_create_page_if_not_exists(block_data.menu.tab)
	_add_item_to_group(item_name, block_data)

func _button_pressed(item_name):
	var wr = find_parent('mainWorld')
	var BuildTool = wr.find_child('BuildTool')
	BuildTool._set_building(item_name)
	_close()
	pass

func _tab_selector_button_pressed(page_index : int):
	tab_container.current_tab = page_index
