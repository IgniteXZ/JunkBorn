extends CanvasLayer

@onready var painel = $PainelInformacoes
@onready var texto_fase = $PainelInformacoes/Fase
@onready var texto_agua = $PainelInformacoes/VelocidadeAgua

var fase_txt = ""
var agua_txt = ""


func _ready():
	# Esconde os labels que não são mais usados
	for nome in ["Tempo", "CanosRestantes"]:
		var no = $PainelInformacoes.get_node_or_null(nome)
		if no:
			no.visible = false

	# Painel compacto, centralizado e colado no topo
	painel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	painel.custom_minimum_size = Vector2(380, 40)
	painel.size = Vector2(380, 40)
	painel.offset_left = -190
	painel.offset_right = 190
	painel.offset_top = 8
	painel.offset_bottom = 48

	# Fase à esquerda, água à direita, dentro do painel compacto
	for l in [texto_fase, texto_agua]:
		l.add_theme_font_size_override("font_size", 18)
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	texto_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto_fase.offset_left = 16
	texto_agua.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	texto_agua.offset_right = -16


func atualizar_tempo(_segundos):
	# O relógio foi removido
	pass


func atualizar_canos(_texto):
	# A seleção de canos agora é a barra embaixo
	pass


func atualizar_fase(atual, total):
	texto_fase.text = "FASE %d/%d" % [atual, total]


func atualizar_velocidade(texto):
	texto_agua.text = "ÁGUA: " + texto
