extends CanvasLayer

@onready var painel = $PainelInformacoes

var texto_unico: Label
var fase_txt = ""
var agua_txt = ""


func _ready():
	# Esconde os labels antigos
	for nome in ["Fase", "Tempo", "VelocidadeAgua", "CanosRestantes"]:
		var no = painel.get_node_or_null(nome)
		if no:
			no.visible = false

	# Painel compacto, centralizado e colado no topo
	painel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	painel.offset_left = -190
	painel.offset_right = 190
	painel.offset_top = 8
	painel.offset_bottom = 48

	# Um único texto, centralizado
	texto_unico = Label.new()
	texto_unico.set_anchors_preset(Control.PRESET_FULL_RECT)
	texto_unico.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_unico.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto_unico.add_theme_font_size_override("font_size", 18)
	texto_unico.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(texto_unico)

	_redesenhar()


func _redesenhar():
	if texto_unico:
		texto_unico.text = "%s   |   %s" % [fase_txt, agua_txt]


func atualizar_tempo(_segundos):
	pass


func atualizar_canos(_texto):
	pass


func atualizar_fase(atual, total):
	fase_txt = "FASE %d/%d" % [atual, total]
	_redesenhar()


func atualizar_velocidade(texto):
	agua_txt = "ÁGUA: " + texto
	_redesenhar()
