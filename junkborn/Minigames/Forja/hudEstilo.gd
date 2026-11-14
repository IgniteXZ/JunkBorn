
class_name HudEstilo
extends RefCounted
## Estilo compartilhado das telas de Forja e Prensa.
## Salve em res://Minigames/Forja/hud_estilo.gd
 
const COR_TEXTO := Color("f5e6d0")
const COR_TITULO := Color("f0c080")
const COR_OK := Color("8fd16a")
const COR_FALTA := Color("e0715c")
const COR_BORDA := Color("a0623f")
 
static func _caixa(fundo: Color, borda: Color, largura: int, margem: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fundo
	sb.border_color = borda
	sb.set_border_width_all(largura)
	sb.set_content_margin_all(margem)
	return sb
 
static func criar_theme() -> Theme:
	var t := Theme.new()
	# Todo PanelContainer (slots) usa este estilo compacto
	t.set_stylebox("panel", "PanelContainer", _caixa(Color(0.08, 0.07, 0.07, 0.9), Color("5a4032"), 3, 6))
	# Botões
	t.set_stylebox("normal", "Button", _caixa(Color("5a3a28"), COR_BORDA, 3, 10))
	t.set_stylebox("hover", "Button", _caixa(Color("7a4e34"), Color("d99a5b"), 3, 10))
	t.set_stylebox("pressed", "Button", _caixa(Color("3e281b"), COR_BORDA, 3, 10))
	t.set_stylebox("disabled", "Button", _caixa(Color(0.18, 0.16, 0.16, 0.9), Color("3e3029"), 3, 10))
	t.set_color("font_color", "Button", COR_TEXTO)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.35))
	t.set_font_size("font_size", "Button", 20)
	# Textos
	t.set_color("font_color", "Label", COR_TEXTO)
	t.set_font_size("font_size", "Label", 18)
	# Tooltip (texto que aparece ao passar o mouse)
	t.set_stylebox("panel", "TooltipPanel", _caixa(Color(0.08, 0.07, 0.07, 0.97), COR_BORDA, 3, 8))
	t.set_color("font_color", "TooltipLabel", COR_TEXTO)
	t.set_font_size("font_size", "TooltipLabel", 18)
	return t
 
## Aplica o tema na raiz da tela (os filhos herdam).
static func aplicar(raiz: Control) -> void:
	raiz.theme = criar_theme()
	raiz.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 
## Fundo grande de janela (o painel principal, não os slots).
static func estilizar_janela(painel: Control) -> void:
	painel.add_theme_stylebox_override("panel", _caixa(Color(0.12, 0.10, 0.10, 0.94), COR_BORDA, 4, 16))
 
## Embrulha o `alvo` (o HBox principal) numa VBox com título + separador em cima.
## criar_janela = true  -> também cria o painel de fundo (usar na Forja, que não tem).
## criar_janela = false -> usar na Prensa, que já tem o seu PanelContainer.
static func embrulhar_com_titulo(alvo: Control, texto: String, criar_janela: bool = false) -> void:
	var pai := alvo.get_parent()
	var indice := alvo.get_index()
 
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 10)
 
	if criar_janela:
		var janela := PanelContainer.new()
		estilizar_janela(janela)
		pai.add_child(janela)
		pai.move_child(janela, indice)
		janela.add_child(caixa)
		# Centralizada embaixo e do tamanho do conteúdo (responsivo)
		janela.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		janela.grow_horizontal = Control.GROW_DIRECTION_BOTH
		janela.grow_vertical = Control.GROW_DIRECTION_BEGIN
		janela.offset_left = 0
		janela.offset_right = 0
		janela.offset_top = -24
		janela.offset_bottom = -24
	else:
		pai.add_child(caixa)
		pai.move_child(caixa, indice)
 
	alvo.reparent(caixa)
 
	var titulo := Label.new()
	titulo.text = texto
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 26)
	titulo.add_theme_color_override("font_color", COR_TITULO)
	caixa.add_child(titulo)
	caixa.move_child(titulo, 0)
 
	var sep := HSeparator.new()
	caixa.add_child(sep)
	caixa.move_child(sep, 1)
 
## Ancora uma tela na borda da janela (responsivo). Para usar depois,
## quando eu souber onde as telas entram na cena.
static func ancorar(
		raiz: Control,
		preset: Control.LayoutPreset,
		margem: int = 40,
		modo: Control.LayoutPresetMode = Control.PRESET_MODE_KEEP_SIZE) -> void:
	await raiz.get_tree().process_frame
	if is_instance_valid(raiz):
		raiz.set_anchors_and_offsets_preset(preset, modo, margem)
 
## Quebra um texto em linhas de no máximo `max_chars` caracteres,
## para o tooltip não ficar gigante de largura.
static func quebrar_linhas(texto: String, max_chars: int = 36) -> String:
	var paragrafos := PackedStringArray()
	for par in texto.split("\n"):
		var linhas := PackedStringArray()
		var atual := ""
		for palavra in par.split(" ", false):
			if atual != "" and atual.length() + 1 + palavra.length() > max_chars:
				linhas.append(atual)
				atual = palavra
			elif atual == "":
				atual = palavra
			else:
				atual += " " + palavra
		if atual != "":
			linhas.append(atual)
		paragrafos.append("\n".join(linhas))
	return "\n".join(paragrafos)
 
