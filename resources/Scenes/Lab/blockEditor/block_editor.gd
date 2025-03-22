extends Control

@onready var code_edit: CodeEdit = $CodeEdit
@onready var codeHighlighter : CodeHighlighter = CodeHighlighter.new()

var keywords = ["return", "if", "else"]
var Flow_keywords = ["extends", "func", "var"]
var block_classes = ["BaseBlock", "BaseInventoryBlock", "BaseLogisticsBlock"]

"""
ff786b - chave incompativel - erro na sintaxe
bce0ff - variavel
ff786b4d - marcação
"""

func _ready() -> void:
	code_edit.syntax_highlighter = codeHighlighter
	code_edit.text_changed.connect(_text_updated)
	
	codeHighlighter.number_color = Color("#a1ffe0")
	codeHighlighter.symbol_color = Color("#abc9ff")
	codeHighlighter.function_color = Color("#57b3ff")
	
	codeHighlighter.add_color_region('"', '"', Color("#ffeda1"), true)
	codeHighlighter.add_color_region('#', '', Color("#cdcfd280"), true)
	
	for keyword in keywords:
		codeHighlighter.keyword_colors[keyword] = Color("ff7085")
	
	for Flow_keyword in Flow_keywords:
		codeHighlighter.keyword_colors[Flow_keyword] = Color("ff8ccc")
	
	for block_class in block_classes:
		codeHighlighter.keyword_colors[block_class] = Color("#c7ffed")

func _show_completion():
	for key in keywords + block_classes:
		code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, key, key)

func check_syntax(code: String) -> Array:
	var script := GDScript.new()
	var errors := []
	
	script.set_source_code(code)
	print("Script carregado para verificação!")
	
	var error = script.reload()
	if error != OK:
		errors.append("Erro de sintaxe: " + error_string(error))  # Converte código de erro para texto
		push_error("Erro de sintaxe detectado!")
	
	return errors


func _text_updated():
	_show_completion()
	code_edit.update_code_completion_options(true)
	
	var errors = check_syntax(code_edit.text)
	if errors.size() > 0:
		print(errors)
		#codeHighlighter.keyword_colors["Erro"] = Color("#ff0000")  # Vermelho para erros
		#code_edit.add_gutter_overlay(0, "Erro de Sintaxe!", Color(1, 0, 0, 1))  # Exibe no lado esquerdo
