extends Node2D

@export var cena_minigame: PackedScene
@export var tex_reto: Texture2D
@export var tex_curva: Texture2D
@export var tex_cruz: Texture2D
@export var tex_pa: Texture2D

@onready var area = $Area2D

var jogador_dentro = false
var aberto = false
var contagem_inicial = {}

var camada_aviso: CanvasLayer
var aviso: Label
var camada_minigame: CanvasLayer
var camada_botao: CanvasLayer


func _ready():
	area.body_entered.connect(_ao_entrar)
	area.body_exited.connect(_ao_sair)

	camada_aviso = CanvasLayer.new()
	camada_aviso.layer = 4
	add_child(camada_aviso)

	aviso = Label.new()
	aviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	aviso.offset_top = -100
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.add_theme_font_size_override("font_size", 24)
	aviso.add_theme_constant_override("outline_size", 8)
	aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	aviso.visible = false
	camada_aviso.add_child(aviso)


func _ao_entrar(body):
	if body.is_in_group("player"):
		jogador_dentro = true


func _ao_sair(body):
	if body.is_in_group("player"):
		jogador_dentro = false
		aviso.visible = false


func _process(_delta):
	if not jogador_dentro or aberto:
		return

	var c = contar()

	if requisitos_ok(c):
		aviso.text = "Aperte E para interagir"
	else:
		aviso.text = "Você precisa de %d canos no total e 1 pá.\nVocê tem %d canos e %d pá(s)." \
			% [MinigameCanos.MINIMO_TOTAL, total_canos(c), c["pa"]]

	aviso.visible = true


func _unhandled_input(event):
	if not jogador_dentro or aberto:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		abrir(true)


# ---------------------------------------------------------------
# INVENTÁRIO (lido pelo sprite)
# ---------------------------------------------------------------

func chave_da_textura(tex) -> String:
	if tex == tex_reto:
		return "reto"
	if tex == tex_curva:
		return "curva"
	if tex == tex_cruz:
		return "cruz"
	if tex == tex_pa:
		return "pa"
	return ""


func contar() -> Dictionary:
	var r = {"reto": 0, "curva": 0, "cruz": 0, "pa": 0}
	var grade = get_tree().get_first_node_in_group("grade_inventario")

	if grade == null:
		return r

	for slot in grade.get_children():
		var spr = slot.get_node_or_null("sprite")
		var qtd_label = slot.get_node_or_null("amount")

		if spr == null or qtd_label == null or spr.texture == null:
			continue

		var chave = chave_da_textura(spr.texture)

		if chave != "":
			r[chave] += max(1, int(qtd_label.text))

	return r


func total_canos(c: Dictionary) -> int:
	return c["reto"] + c["curva"] + c["cruz"]


func requisitos_ok(c: Dictionary) -> bool:
	return total_canos(c) >= MinigameCanos.MINIMO_TOTAL and c["pa"] >= 1


func debitar(gasto: Dictionary):
	var grade = get_tree().get_first_node_in_group("grade_inventario")

	if grade == null:
		return

	for slot in grade.get_children():
		var spr = slot.get_node_or_null("sprite")
		var qtd_label = slot.get_node_or_null("amount")

		if spr == null or qtd_label == null or spr.texture == null:
			continue

		var chave = chave_da_textura(spr.texture)

		if chave == "" or chave == "pa" or gasto.get(chave, 0) <= 0:
			continue

		var qtd = max(1, int(qtd_label.text))
		var tirar = min(qtd, gasto[chave])
		gasto[chave] -= tirar

		if qtd - tirar <= 0:
			slot.set_empty_slot()
		else:
			qtd_label.text = str(qtd - tirar)

	var dono = grade.get_parent().get_parent() if grade.get_parent() else null

	if dono and dono.has_method("salvar_inventario"):
		dono.salvar_inventario()


# ---------------------------------------------------------------
# ABRIR E FECHAR O MINIGAME
# ---------------------------------------------------------------

func abrir(verificar: bool):
	if verificar:
		var c = contar()

		if not requisitos_ok(c):
			return

		contagem_inicial = {"reto": c["reto"], "curva": c["curva"], "cruz": c["cruz"]}

		MinigameCanos.fase_atual = 0
		MinigameCanos.reserva = {}
		MinigameCanos.mapa_salvo = []
		MinigameCanos.inventario = contagem_inicial.duplicate()

	aberto = true
	aviso.visible = false
	congelar_jogador(true)

	camada_minigame = CanvasLayer.new()
	camada_minigame.layer = 5
	add_child(camada_minigame)

	var fundo = ColorRect.new()
	fundo.color = Color(0.05, 0.05, 0.08, 1.0)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada_minigame.add_child(fundo)

	var instancia = cena_minigame.instantiate()
	camada_minigame.add_child(instancia)

	var hud = instancia.get_node_or_null("HUD")
	if hud:
		hud.layer = 6

	var tabuleiro = instancia.get_node("board")
	tabuleiro.sair_solicitado.connect(_ao_sair_do_minigame)
	tabuleiro.reiniciar_solicitado.connect(_ao_reiniciar)
	tabuleiro.minigame_concluido.connect(_ao_concluir)

	camada_botao = CanvasLayer.new()
	camada_botao.layer = 30
	add_child(camada_botao)

	var botao = Button.new()
	botao.text = "Sair"
	botao.position = Vector2(20, 20)
	botao.custom_minimum_size = Vector2(100, 40)
	botao.pressed.connect(_ao_sair_do_minigame)
	camada_botao.add_child(botao)


func fechar():
	if camada_minigame:
		camada_minigame.queue_free()
	if camada_botao:
		camada_botao.queue_free()

	camada_minigame = null
	camada_botao = null
	aberto = false
	congelar_jogador(false)


func congelar_jogador(congelar: bool):
	for p in get_tree().get_nodes_in_group("player"):
		p.set_process(not congelar)
		p.set_physics_process(not congelar)
		p.set_process_input(not congelar)
		p.set_process_unhandled_input(not congelar)


func _ao_sair_do_minigame():
	# Sair no meio = descartar a reserva; o inventário real não muda
	MinigameCanos.fase_atual = 0
	MinigameCanos.reserva = {}
	MinigameCanos.mapa_salvo = []
	fechar()


func _ao_reiniciar():
	fechar()
	abrir(false)


func _ao_concluir():
	var gasto = {}

	for t in ["reto", "curva", "cruz"]:
		gasto[t] = max(0, contagem_inicial[t] - MinigameCanos.inventario[t])

	debitar(gasto)
	fechar()
