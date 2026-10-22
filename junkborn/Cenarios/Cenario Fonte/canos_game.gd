extends Node2D

@export var cena_minigame: PackedScene
@export var tex_cano: Texture2D
@export var tex_pa: Texture2D
@export var tex_picareta: Texture2D
@export var modo_teste = false

@onready var area = $Area2D

var jogador_dentro = false
var aberto = false

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
		aviso.text = "Você precisa de um cano e uma pá para usar a fonte."

	aviso.visible = true


func _unhandled_input(event):
	if not jogador_dentro or aberto:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		abrir()


# ---------------------------------------------------------------
# INVENTÁRIO (lido pelo sprite, como na forja)
# ---------------------------------------------------------------

func obter_slots() -> Array:
	var slots = []
	var jogador = get_tree().get_first_node_in_group("player")

	if jogador == null:
		return slots

	for no in jogador.find_children("*", "Control", true, false):
		if no.has_method("set_empty_slot"):
			slots.append(no)

	return slots


func mesma_textura(a, b) -> bool:
	if a == null or b == null:
		return false
	if a == b:
		return true
	return a.resource_path != "" and a.resource_path == b.resource_path


func chave_da_textura(tex) -> String:
	if mesma_textura(tex, tex_cano):
		return "cano"
	if mesma_textura(tex, tex_pa):
		return "pa"
	if mesma_textura(tex, tex_picareta):
		return "picareta"
	return ""


func contar() -> Dictionary:
	if modo_teste:
		return {"cano": 1, "pa": 1, "picareta": 0}

	var r = {"cano": 0, "pa": 0, "picareta": 0}

	for slot in obter_slots():
		var spr = slot.get_node_or_null("sprite")

		if spr == null or spr.texture == null:
			continue

		var chave = chave_da_textura(spr.texture)

		if chave != "":
			r[chave] += 1

	return r


func requisitos_ok(c: Dictionary) -> bool:
	return c["cano"] >= 1 and c["pa"] >= 1


# ---------------------------------------------------------------
# ABRIR E FECHAR O MINIGAME
# ---------------------------------------------------------------

func abrir():
	if cena_minigame == null:
		push_error("canosGame: arraste a cena do minigame para 'Cena Minigame' no Inspetor.")
		return

	if not requisitos_ok(contar()):
		return

	MinigameCanos.fase_atual = 0
	MinigameCanos.mapa_salvo = []

	_montar()


func _montar():
	aberto = true
	aviso.visible = false
	add_to_group("minigame_aberto")
	congelar_jogador(true)

	camada_minigame = CanvasLayer.new()
	camada_minigame.layer = 5
	add_child(camada_minigame)

	var instancia = cena_minigame.instantiate()
	camada_minigame.add_child(instancia)

	var hud = instancia.get_node_or_null("HUD")
	if hud:
		hud.layer = 6

	var tabuleiro = instancia.get_node("board")
	tabuleiro.sair_solicitado.connect(_ao_sair_do_minigame)
	tabuleiro.reiniciar_solicitado.connect(_ao_reiniciar)
	tabuleiro.minigame_concluido.connect(_ao_concluir)
	tabuleiro.definir_picareta(contar()["picareta"] >= 1)

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
	remove_from_group("minigame_aberto")
	congelar_jogador(false)


func congelar_jogador(congelar: bool):
	for p in get_tree().get_nodes_in_group("player"):
		p.set_process(not congelar)
		p.set_physics_process(not congelar)
		p.set_process_input(not congelar)
		p.set_process_unhandled_input(not congelar)


func _ao_sair_do_minigame():
	MinigameCanos.fase_atual = 0
	MinigameCanos.mapa_salvo = []
	fechar()


func _ao_reiniciar():
	# Tentar de novo / próxima fase: fecha e reabre sem rechecar requisitos
	fechar()
	_montar()


func _ao_concluir():
	# Nada é consumido: o cano e a pá são "chaves"
	fechar()
