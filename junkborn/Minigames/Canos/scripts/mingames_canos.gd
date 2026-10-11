class_name MinigameCanos
extends Node2D

signal minigame_concluido
signal sair_solicitado
signal reiniciar_solicitado

const TAMANHO_CELULA = 48
const RAIO_CURVA = 24.0
const LARGURA_AGUA = 10.0
const LARGURA_CONTORNO = 14.0

# Requisito simples: o lago confere 1 de cada tipo + pá (ajuste no canos_game.gd)
const MINIMO_TOTAL = 3

const TIPOS = ["reto", "curva", "cruz"]

const CURIOSIDADES = [
	{
		"titulo": "Impactos no cotidiano",
		"texto": "Quanto mais poluído o rio, mais produtos químicos o tratamento exige, e a conta de água sobe para todas as famílias. Poluentes corrosivos também entopem e desgastam as tubulações, causando manutenções e falta de água. Muita gente acaba trocando a torneira por água mineral, o que pesa no orçamento.",
	},
	{
		"titulo": "Como se trata a água",
		"texto": "Cada tipo de contaminação pede um tratamento diferente. Na biológica, a água passa por coagulação, floculação, decantação, filtragem e desinfecção com cloro ou luz UV. Alguns poluentes, como PFAS e radiação, não têm tratamento viável em larga escala.",
	},
	{
		"titulo": "Os 5 tipos de contaminação",
		"texto": "Biológica: micro-organismos de esgoto, maior causa de doenças pela água.\nQuímica: agrotóxicos, petróleo e metais pesados, que chegam a nós pela cadeia alimentar.\nTérmica: água quente de fábricas, que retém menos oxigênio e sufoca os peixes.\nSedimentar: terra solta pelo desmatamento, que turva a água e assoreia o rio.\nRadioativa: resíduos nucleares que alteram o DNA e duram milhares de anos.",
	},
	{
		"titulo": "Poluída ou contaminada?",
		"texto": "Água poluída sofreu alterações químicas ou biológicas pela ação humana e não serve para qualquer uso, mas não transmite doenças de imediato. Água contaminada carrega bactérias, vírus, parasitas ou substâncias tóxicas e é um risco direto à saúde.",
	},
	{
		"titulo": "O que é água contaminada",
		"texto": "É a água que contém bactérias, vírus, parasitas ou substâncias tóxicas e oferece risco a quem bebe ou até só encosta nela. O perigo maior é que nem sempre dá para ver: ela pode parecer limpa, transparente e sem cheiro.",
	},
]

# T = terra, D = chão duro, P = pedra, M = área contaminada (só em terra), S = fonte
const CODIGOS = {"T": 3, "D": 3, "P": 2, "M": 6, "S": 3}

# preview: 0 = livre (botão INICIAR); acima de 0 = segundos, com botão Pular
const FASES = [
	{
		"tamanho": 8, "minas": 10, "pedras": 8, "duros": 5, "desvio": 2,
		"preview": 0, "ocultas": false,
		"velocidade": "LENTA",
		"duracao_celula": 2.5, "tolerancia": 0.3, "folga": 5.0,
	},
	{
		"tamanho": 9, "minas": 17, "pedras": 11, "duros": 10, "desvio": 3,
		"preview": 20, "ocultas": true,
		"velocidade": "MÉDIA",
		"duracao_celula": 2.0, "tolerancia": 0.3, "folga": 5.0,
	},
	{
		"tamanho": 10, "minas": 26, "pedras": 14, "duros": 14, "desvio": 4,
		"preview": 30, "ocultas": true,
		"velocidade": "RÁPIDA",
		"duracao_celula": 1.5, "tolerancia": 0.3, "folga": 5.0,
	},
]

# Persistem quando a cena é recarregada (tentar de novo / próxima fase)
static var fase_atual = 0
static var tutorial_visto = false
static var mapa_salvo = []
# O lago grava aqui o que o jogador tem; ao concluir tudo, sai 1 de cada tipo
static var inventario = {"reto": 1, "curva": 1, "cruz": 1}
static var reserva = {}

# Texto provisório (você vai mandar o definitivo)
const PAGINAS_TUTORIAL = [
	["OBJETIVO", "Leve a água que sai do bloco azul até o topo do tabuleiro, montando uma tubulação.\nDepois do VAI!, a água sai sozinha em 5 segundos e não espera ninguém."],
	["CONTROLES", "Botão DIREITO: cava a terra (chão acinzentado é duro e leva 2 cliques).\nBotão ESQUERDO: coloca um cano na terra cavada. Clicar num cano o gira, só até a água chegar nele."],
	["OS CANOS", "Teclas 1, 2 e 3 trocam o cano.\n1 Reto: liga dois lados opostos.\n2 Curva: liga dois lados vizinhos.\n3 Cruz: liga os quatro lados e divide a água. Todos os lados precisam ter cano."],
	["CUIDADO", "Áreas contaminadas (verdes): clicar nelas, ou deixar a água chegar perto delas, faz você perder. Pedras não aceitam cano.\nVocê também perde se a água vazar ou chegar onde não há cano.\nNas fases 2 e 3 as áreas contaminadas somem depois do preview. Memorize onde estão!"],
]

var fase: Dictionary
var colunas = 8
var linhas = 8
var fonte = Vector2i.ZERO
var celulas = []

var tipo_cano_selecionado = 0

var duracao_celula = 2.5
var tempo_espera_agua = 0.3
var folga_agua = 5.0

var cena_celula = preload("res://Minigames/Canos/tscn/cell.tscn")
@onready var hud = get_parent().get_node("HUD")

var camada_contornos: Node2D
var camada_agua: Node2D

var jogando = false
var agua_movendo = false
var partida_encerrada = false

var modo_intro = ""
var pagina_tutorial = 0
var preview_pulado = false
var camada_intro: CanvasLayer
var painel_intro: PanelContainer
var titulo_intro: Label
var texto_intro: Label
var botao_principal: Button
var botao_pular: Button
var rotulo_contagem: Label


# Uma "trilha" de água = linha principal + contorno escuro
class Trilha:
	var agua: Line2D
	var contorno: Line2D

	func adicionar_ponto(p: Vector2):
		agua.add_point(p)
		contorno.add_point(p)

	func definir_ponto(i: int, p: Vector2):
		agua.set_point_position(i, p)
		contorno.set_point_position(i, p)

	func total_pontos() -> int:
		return agua.get_point_count()


func _ready():
	fase = FASES[fase_atual]

	if mapa_salvo.is_empty():
		mapa_salvo = gerar_mapa(
			fase["tamanho"],
			fase["minas"],
			fase["pedras"],
			fase["duros"],
			fase["desvio"]
		)

	var mapa = mapa_salvo
	linhas = mapa.size()
	colunas = mapa[0].size()

	duracao_celula = fase["duracao_celula"]
	tempo_espera_agua = fase["tolerancia"]
	folga_agua = fase["folga"]

	var tamanho = Vector2(colunas, linhas) * TAMANHO_CELULA
	var vp = get_viewport_rect().size
	position = Vector2((vp.x - tamanho.x) / 2.0, 130.0) \
		+ Vector2(TAMANHO_CELULA, TAMANHO_CELULA) / 2.0

	for y in range(linhas):
		celulas.append([])

		for x in range(colunas):
			var letra = mapa[y][x]
			var celula = cena_celula.instantiate()

			celula.position = Vector2(x * TAMANHO_CELULA, y * TAMANHO_CELULA)
			add_child(celula)
			celula.definir_terreno(CODIGOS[letra])

			if letra == "D":
				celula.definir_duro()

			celula.definir_posicao(x, y)
			celulas[y].append(celula)

			if letra == "S":
				fonte = Vector2i(x, y)
				celula.marcar_fonte()

	var no_fonte = get_node_or_null("FonteAgua")
	if no_fonte:
		no_fonte.position = obter_ponto_centro(fonte)

	camada_contornos = Node2D.new()
	add_child(camada_contornos)
	camada_agua = Node2D.new()
	add_child(camada_agua)

	hud.atualizar_fase.call_deferred(fase_atual + 1, FASES.size())
	hud.atualizar_velocidade.call_deferred(fase["velocidade"])
	limpar_texto_tempo.call_deferred()
	atualizar_hud_canos.call_deferred()

	iniciar_intro()


# O relógio foi removido: esvazia o texto do tempo no HUD
func limpar_texto_tempo():
	var lt = hud.get_node_or_null("PainelInformacoes/Tempo")
	if lt:
		lt.text = ""


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			tipo_cano_selecionado = 0
		elif event.keycode == KEY_2:
			tipo_cano_selecionado = 1
		elif event.keycode == KEY_3:
			tipo_cano_selecionado = 2
		else:
			return
		atualizar_hud_canos()


# ---------------------------------------------------------------
# CANOS (infinitos)
# ---------------------------------------------------------------

func atualizar_hud_canos():
	var nomes = ["1 RETO", "2 CURVA", "3 CRUZ"]
	var partes = []

	for i in range(nomes.size()):
		var s = nomes[i]
		if i == tipo_cano_selecionado:
			s = "[" + s + "]"
		partes.append(s)

	hud.atualizar_canos("  ".join(partes))


func tentar_colocar_cano(celula):
	if not jogando or partida_encerrada:
		return

	if not celula.pode_receber_cano() or celula.cano_colocado:
		return

	celula.colocar_cano(tipo_cano_selecionado)


# ---------------------------------------------------------------
# INTRO: tutorial, preview e contagem
# ---------------------------------------------------------------

func iniciar_intro():
	jogando = false
	criar_interface_intro()

	if tutorial_visto:
		mostrar_preview()
	else:
		pagina_tutorial = 0
		mostrar_pagina_tutorial()


func criar_interface_intro():
	var vp = get_viewport_rect().size

	camada_intro = CanvasLayer.new()
	camada_intro.layer = 10
	add_child(camada_intro)

	var fundo = ColorRect.new()
	fundo.color = Color(0.1, 0.1, 0.1, 0.45)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	camada_intro.add_child(fundo)

	# Painel na lateral, para o mapa ficar visível no preview
	painel_intro = PanelContainer.new()
	painel_intro.custom_minimum_size = Vector2(330, 0)
	painel_intro.position = Vector2(vp.x - 360, 200)
	camada_intro.add_child(painel_intro)

	var caixa = VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 8)
	painel_intro.add_child(caixa)

	titulo_intro = Label.new()
	titulo_intro.add_theme_font_size_override("font_size", 22)
	titulo_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo_intro)

	texto_intro = Label.new()
	texto_intro.add_theme_font_size_override("font_size", 15)
	texto_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_intro.custom_minimum_size = Vector2(300, 0)
	caixa.add_child(texto_intro)

	var botoes = HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_CENTER
	botoes.add_theme_constant_override("separation", 12)
	caixa.add_child(botoes)

	botao_pular = Button.new()
	botao_pular.pressed.connect(_ao_clicar_pular)
	botoes.add_child(botao_pular)

	botao_principal = Button.new()
	botao_principal.pressed.connect(_ao_clicar_principal)
	botoes.add_child(botao_principal)

	rotulo_contagem = Label.new()
	rotulo_contagem.set_anchors_preset(Control.PRESET_FULL_RECT)
	rotulo_contagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo_contagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rotulo_contagem.add_theme_font_size_override("font_size", 120)
	rotulo_contagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rotulo_contagem.pivot_offset = vp / 2.0
	rotulo_contagem.visible = false
	camada_intro.add_child(rotulo_contagem)


func mostrar_pagina_tutorial():
	modo_intro = "tutorial"
	var pagina = PAGINAS_TUTORIAL[pagina_tutorial]
	titulo_intro.text = pagina[0]
	texto_intro.text = pagina[1]
	var ultima = pagina_tutorial == PAGINAS_TUTORIAL.size() - 1
	botao_principal.visible = true
	botao_principal.text = "Entendi" if ultima else "Próximo"
	botao_pular.text = "Pular tutorial"
	botao_pular.visible = true


func mostrar_preview():
	modo_intro = "preview"
	preview_pulado = false
	titulo_intro.text = "FASE %d: PLANEJE" % (fase_atual + 1)

	var base = "Cave (botão direito) e coloque canos (botão esquerdo) da fonte até o topo, desviando das áreas contaminadas (verdes) e das pedras (cinza)."
	var extra = "\n\nAs áreas contaminadas vão DESAPARECER. Memorize onde estão!" if fase["ocultas"] else ""

	if fase["preview"] > 0:
		botao_principal.visible = false
		botao_pular.text = "Pular"
		botao_pular.visible = true

		var restante = int(fase["preview"])
		while restante > 0 and not preview_pulado:
			texto_intro.text = "%s%s\n\nComeça em %d s..." % [base, extra, restante]
			await get_tree().create_timer(1.0).timeout
			restante -= 1

		comecar_contagem()
	else:
		texto_intro.text = base + extra + "\n\nQuando estiver pronto, clique em INICIAR."
		botao_principal.text = "INICIAR"
		botao_principal.visible = true
		botao_pular.visible = false


func _ao_clicar_principal():
	if modo_intro == "tutorial":
		pagina_tutorial += 1
		if pagina_tutorial >= PAGINAS_TUTORIAL.size():
			tutorial_visto = true
			mostrar_preview()
		else:
			mostrar_pagina_tutorial()
	elif modo_intro == "preview":
		comecar_contagem()


func _ao_clicar_pular():
	if modo_intro == "tutorial":
		tutorial_visto = true
		mostrar_preview()
	elif modo_intro == "preview":
		# Encerra o preview com tempo; o laço do preview inicia a contagem
		preview_pulado = true


func comecar_contagem():
	if modo_intro == "contagem":
		return

	modo_intro = "contagem"
	painel_intro.visible = false
	rotulo_contagem.visible = true

	if fase["ocultas"]:
		esconder_minas()

	for passo in ["3", "2", "1", "VAI!"]:
		rotulo_contagem.text = passo
		rotulo_contagem.scale = Vector2(1.6, 1.6)

		var tween = create_tween()
		tween.tween_property(rotulo_contagem, "scale", Vector2.ONE, 0.5)

		await get_tree().create_timer(0.8).timeout

	camada_intro.queue_free()
	jogando = true
	iniciar_fluxo_agua()


func esconder_minas():
	for linha in celulas:
		for c in linha:
			if c.eh_mina():
				c.ocultar_mina()


# ---------------------------------------------------------------
# FLUXO DA ÁGUA
# ---------------------------------------------------------------

func achar_saidas_fonte() -> Array:
	var saidas = []

	for direcao in ["cima", "direita", "esquerda", "baixo"]:
		var p = obter_proxima_posicao(fonte, direcao)

		if p.x < 0 or p.x >= colunas or p.y < 0 or p.y >= linhas:
			continue

		var c = celulas[p.y][p.x]

		if c.cano_colocado and obter_direcao_oposta(direcao) in c.obter_conexoes():
			saidas.append(direcao)

	return saidas


func iniciar_fluxo_agua():
	if partida_encerrada or agua_movendo:
		return

	agua_movendo = true

	await contagem_folga()

	if partida_encerrada:
		return

	var direcoes = []
	var decorrido = 0.0

	while true:
		direcoes = achar_saidas_fonte()

		if direcoes.size() > 0 or decorrido > tempo_espera_agua:
			break

		await get_tree().create_timer(0.05).timeout

		if partida_encerrada:
			return

		decorrido += 0.05

	if direcoes.is_empty():
		derrotar_jogo("sem_cano")
		return

	for d in direcoes:
		sair_da_fonte(d)


# Mostra "A água sai em Xs" durante a folga inicial
func contagem_folga():
	var camada = CanvasLayer.new()
	camada.layer = 7
	add_child(camada)

	var rotulo = Label.new()
	rotulo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rotulo.offset_top = 190
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.add_theme_font_size_override("font_size", 24)
	rotulo.add_theme_constant_override("outline_size", 8)
	rotulo.add_theme_color_override("font_outline_color", Color.BLACK)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	camada.add_child(rotulo)

	var restante = folga_agua

	while restante > 0.0 and not partida_encerrada:
		rotulo.text = "A água sai em %d s" % ceili(restante)
		await get_tree().create_timer(0.1).timeout
		restante -= 0.1

	camada.queue_free()


func sair_da_fonte(direcao: String):
	var primeira = obter_proxima_posicao(fonte, direcao)
	var entrada = obter_direcao_oposta(direcao)
	var trilha = criar_trilha()

	await animar_caminho(
		trilha,
		[obter_ponto_centro(fonte), obter_ponto_borda(primeira, entrada)],
		0.25
	)

	if partida_encerrada:
		return

	await fluxir(primeira, entrada, trilha)


func fluxir(pos: Vector2i, entrada: String, trilha: Trilha):
	while not partida_encerrada:
		var celula = celulas[pos.y][pos.x]

		if not await esperar_conexao(celula, entrada):
			if not partida_encerrada:
				derrotar_jogo("sem_cano")
			return

		celula.agua_chegou = true

		if tem_contaminacao_ao_redor(celula):
			derrotar_jogo("contaminacao")
			return

		var saidas = []
		for direcao in celula.obter_conexoes():
			if direcao != entrada:
				saidas.append(direcao)

		if saidas.size() == 1:
			var saida = saidas[0]

			await animar_caminho(
				trilha,
				obter_pontos_celula(pos, entrada, saida),
				duracao_celula
			)

			if partida_encerrada:
				return

			if not avancar(pos, saida):
				return

			pos = obter_proxima_posicao(pos, saida)
			entrada = obter_direcao_oposta(saida)
			continue

		# Cruz: vai ao centro e ramifica
		await animar_caminho(
			trilha,
			[obter_ponto_borda(pos, entrada), obter_ponto_centro(pos)],
			duracao_celula * 0.5
		)

		if partida_encerrada:
			return

		for saida in saidas:
			ramificar(pos, saida)

		return


func ramificar(pos: Vector2i, saida: String):
	var trilha = criar_trilha()

	await animar_caminho(
		trilha,
		[obter_ponto_centro(pos), obter_ponto_borda(pos, saida)],
		duracao_celula * 0.5
	)

	if partida_encerrada:
		return

	if not avancar(pos, saida):
		return

	await fluxir(
		obter_proxima_posicao(pos, saida),
		obter_direcao_oposta(saida),
		trilha
	)


func avancar(pos: Vector2i, saida: String) -> bool:
	var proxima = obter_proxima_posicao(pos, saida)

	if proxima == fonte:
		derrotar_jogo("vazamento")
		return false

	if proxima.y < 0:
		ganhar_jogo()
		return false

	if proxima.x < 0 or proxima.x >= colunas or proxima.y >= linhas:
		derrotar_jogo("vazamento")
		return false

	return true


func esperar_conexao(celula, entrada: String) -> bool:
	var decorrido = 0.0

	while decorrido <= tempo_espera_agua:
		if celula.cano_colocado and entrada in celula.obter_conexoes():
			return true

		await get_tree().create_timer(0.05).timeout

		if partida_encerrada:
			return false

		decorrido += 0.05

	return false


func tem_contaminacao_ao_redor(celula) -> bool:
	for direcao in celula.obter_conexoes():
		var p = obter_proxima_posicao(
			Vector2i(celula.coluna, celula.linha),
			direcao
		)

		if p.x < 0 or p.x >= colunas or p.y < 0 or p.y >= linhas:
			continue

		if celulas[p.y][p.x].eh_mina():
			return true

	return false


# ---------------------------------------------------------------
# GEOMETRIA E ANIMAÇÃO
# ---------------------------------------------------------------

func obter_proxima_posicao(posicao: Vector2i, direcao: String) -> Vector2i:
	var nova_posicao = posicao

	match direcao:
		"cima":
			nova_posicao.y -= 1
		"baixo":
			nova_posicao.y += 1
		"esquerda":
			nova_posicao.x -= 1
		"direita":
			nova_posicao.x += 1

	return nova_posicao


func obter_direcao_oposta(direcao: String) -> String:
	match direcao:
		"cima":
			return "baixo"
		"baixo":
			return "cima"
		"esquerda":
			return "direita"
		"direita":
			return "esquerda"

	return ""


func obter_vetor_direcao(direcao: String) -> Vector2:
	match direcao:
		"cima":
			return Vector2.UP
		"baixo":
			return Vector2.DOWN
		"esquerda":
			return Vector2.LEFT
		"direita":
			return Vector2.RIGHT

	return Vector2.ZERO


func obter_ponto_centro(celula_posicao: Vector2i) -> Vector2:
	return Vector2(
		celula_posicao.x * TAMANHO_CELULA,
		celula_posicao.y * TAMANHO_CELULA
	)


func obter_ponto_borda(pos: Vector2i, direcao: String) -> Vector2:
	return obter_ponto_centro(pos) \
		+ obter_vetor_direcao(direcao) * (TAMANHO_CELULA / 2.0)


func obter_pontos_celula(pos: Vector2i, entrada: String, saida: String) -> Array:
	var centro = obter_ponto_centro(pos)
	var p_entrada = obter_ponto_borda(pos, entrada)
	var p_saida = obter_ponto_borda(pos, saida)

	if saida == obter_direcao_oposta(entrada):
		return [p_entrada, p_saida]

	var de = obter_vetor_direcao(entrada)
	var ds = obter_vetor_direcao(saida)
	var r = RAIO_CURVA

	var c = centro + (de + ds) * r
	var inicio = centro + de * r
	var fim = centro + ds * r

	var a0 = (inicio - c).angle()
	var a1 = (fim - c).angle()

	var pontos = []

	if inicio.distance_to(p_entrada) > 0.5:
		pontos.append(p_entrada)

	var passos = 16

	for i in range(passos + 1):
		var a = lerp_angle(a0, a1, float(i) / passos)
		pontos.append(c + Vector2.from_angle(a) * r)

	if fim.distance_to(p_saida) > 0.5:
		pontos.append(p_saida)

	return pontos


func criar_trilha() -> Trilha:
	var t = Trilha.new()

	t.contorno = Line2D.new()
	t.contorno.width = LARGURA_CONTORNO
	t.contorno.default_color = Color(0.02, 0.25, 0.55, 0.9)
	configurar_linha(t.contorno)
	camada_contornos.add_child(t.contorno)

	t.agua = Line2D.new()
	t.agua.width = LARGURA_AGUA

	var grad = Gradient.new()
	grad.set_color(0, Color(0.05, 0.45, 0.85, 0.95))
	grad.set_color(1, Color(0.45, 0.92, 1.0, 1.0))
	t.agua.gradient = grad

	configurar_linha(t.agua)
	camada_agua.add_child(t.agua)

	return t


func configurar_linha(linha: Line2D):
	linha.joint_mode = Line2D.LINE_JOINT_ROUND
	linha.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha.antialiased = true


func animar_caminho(trilha: Trilha, pontos: Array, duracao: float):
	var base = trilha.total_pontos()

	for i in range(pontos.size()):
		trilha.adicionar_ponto(pontos[0])

	var tween = create_tween()
	tween.tween_method(
		_atualizar_caminho.bind(trilha, pontos, base),
		0.0,
		1.0,
		duracao
	)

	await tween.finished


func _atualizar_caminho(t: float, trilha: Trilha, pontos: Array, base: int):
	var n = pontos.size()
	var total = 0.0

	for k in range(n - 1):
		total += pontos[k].distance_to(pontos[k + 1])

	var alvo = t * total
	var acumulado = 0.0
	var ultimo = n - 1
	var cabeca = pontos[n - 1]

	for k in range(n - 1):
		var seg = pontos[k].distance_to(pontos[k + 1])

		if alvo <= acumulado + seg:
			if seg > 0.0:
				cabeca = pontos[k].lerp(pontos[k + 1], (alvo - acumulado) / seg)
			else:
				cabeca = pontos[k + 1]
			ultimo = k
			break

		acumulado += seg

	for k in range(n):
		trilha.definir_ponto(base + k, pontos[k] if k <= ultimo else cabeca)


# ---------------------------------------------------------------
# VITÓRIA E DERROTA
# ---------------------------------------------------------------

func ganhar_jogo():
	if partida_encerrada:
		return

	partida_encerrada = true
	agua_movendo = false

	await get_tree().create_timer(0.7).timeout

	if fase_atual < FASES.size() - 1:
		mostrar_resultado("FASE CONCLUÍDA!", "A água chegou ao topo!", "Próxima fase", proxima_fase)
	else:
		mostrar_resultado(
			"TUBULAÇÃO COMPLETA!",
			"Ao concluir, 1 cano de cada tipo sai do seu inventário.",
			"Concluir",
			concluir_minigame
		)


func derrotar_jogo(motivo = "sem_cano"):
	if partida_encerrada:
		return

	partida_encerrada = true
	agua_movendo = false
	revelar_minas()

	var texto = "Você não conseguiu completar a tubulação."

	match motivo:
		"sem_cano":
			texto = "A água chegou onde não havia cano!\nA tubulação não acompanhou o fluxo."
		"mina":
			texto = "Você tocou em uma área contaminada!\nA contaminação tornou a operação impossível."
		"vazamento":
			texto = "A água vazou para fora do tabuleiro!\nA tubulação não conseguiu conter o fluxo."
		"contaminacao":
			texto = "A água encontrou uma área contaminada!\nA contaminação se espalhou pela tubulação."

	texto += "\n\nSeus canos continuam no inventário."

	await get_tree().create_timer(0.7).timeout

	mostrar_resultado("IT'S OVER", texto, "Tentar novamente", reiniciar_fase, CURIOSIDADES.pick_random())


func mostrar_resultado(titulo_txt: String, corpo: String, rotulo_botao: String, acao: Callable, curiosidade: Dictionary = {}):
	var camada = CanvasLayer.new()
	camada.layer = 20
	add_child(camada)

	var fundo = ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.6)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	camada.add_child(fundo)

	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(centro)

	var caixa = VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 16)
	centro.add_child(caixa)

	var titulo = Label.new()
	titulo.text = titulo_txt
	titulo.add_theme_font_size_override("font_size", 56)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo)

	var texto = Label.new()
	texto.text = corpo
	texto.add_theme_font_size_override("font_size", 20)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(texto)

	# --- Curiosidade (só aparece se foi passada) ---
	if not curiosidade.is_empty():
		var painel = PanelContainer.new()
		caixa.add_child(painel)

		var interno = VBoxContainer.new()
		interno.add_theme_constant_override("separation", 6)
		painel.add_child(interno)

		var t = Label.new()
		t.text = "VOCÊ SABIA? " + curiosidade["titulo"]
		t.add_theme_font_size_override("font_size", 18)
		interno.add_child(t)

		var c = Label.new()
		c.text = curiosidade["texto"]
		c.add_theme_font_size_override("font_size", 15)
		c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		c.custom_minimum_size = Vector2(720, 0)
		interno.add_child(c)

	var botao = Button.new()
	botao.text = rotulo_botao
	botao.custom_minimum_size = Vector2(200, 44)
	botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	botao.pressed.connect(acao)
	caixa.add_child(botao)


func reiniciar_fase():
	reiniciar_solicitado.emit()


func proxima_fase():
	fase_atual += 1
	mapa_salvo = []
	reiniciar_solicitado.emit()


func concluir_minigame():
	# Só na vitória final: sai 1 de cada tipo (o lago calcula o gasto por diferença)
	for t in TIPOS:
		inventario[t] = max(0, inventario[t] - 1)

	reserva = {}
	fase_atual = 0
	mapa_salvo = []
	minigame_concluido.emit()


# ---------------------------------------------------------------
# GERADOR DE MAPA
# ---------------------------------------------------------------

func gerar_mapa(n: int, minas: int, pedras: int, duros: int, desvio_min: int) -> Array:
	var melhor = null

	# Se não achar mapa com o desvio pedido, vai relaxando até 0
	for desvio in range(desvio_min, -1, -1):
		for tentativa in range(150):
			var g = montar_mapa(n, minas, pedras, duros)
			var fx = encontrar_fonte(g, n)
			var c = caminho_minimo(g, n, fx)

			if c >= n - 1 + desvio:
				return g
			if c > 0:
				melhor = g

		if melhor != null and desvio < desvio_min:
			return melhor

	return melhor


func encontrar_fonte(g: Array, n: int) -> int:
	for x in range(n):
		if g[n - 1][x] == "S":
			return x
	return 0


func montar_mapa(n: int, minas: int, pedras: int, duros: int) -> Array:
	var g = []
	for y in range(n):
		g.append([])
		for x in range(n):
			g[y].append("T")

	var fx = randi_range(1, n - 2)
	g[n - 1][fx] = "S"

	# Livres: tudo, menos a fonte e os vizinhos dela (cima, esquerda, direita)
	var livres = []
	for y in range(n):
		for x in range(n):
			if abs(x - fx) + (n - 1 - y) <= 1:
				continue
			livres.append(Vector2i(x, y))
	livres.shuffle()

	# Pedras em manchas
	var colocadas = 0
	var tentativas = 0

	while colocadas < pedras and tentativas < 500:
		tentativas += 1
		var o = livres[randi() % livres.size()]
		var tamanho_mancha = randi_range(3, 6)
		var frente = [o]

		while frente.size() > 0 and tamanho_mancha > 0 and colocadas < pedras:
			var p = frente.pop_at(randi() % frente.size())

			if g[p.y][p.x] != "T" or not (p in livres):
				continue

			g[p.y][p.x] = "P"
			colocadas += 1
			tamanho_mancha -= 1

			for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var q = p + d
				if q.x >= 0 and q.x < n and q.y >= 0 and q.y < n:
					frente.append(q)

	var restantes = []
	for p in livres:
		if g[p.y][p.x] == "T":
			restantes.append(p)
	restantes.shuffle()

	var i = 0

	# Áreas contaminadas: só em terra
	for k in range(minas):
		if i >= restantes.size():
			break
		g[restantes[i].y][restantes[i].x] = "M"
		i += 1

	for k in range(duros):
		if i >= restantes.size():
			break
		g[restantes[i].y][restantes[i].x] = "D"
		i += 1

	return g


# Tamanho (em células) do caminho mais curto da fonte até o topo. -1 se não existe.
func caminho_minimo(g: Array, n: int, fx: int) -> int:
	var origem = Vector2i(fx, n - 1)
	var dist = {}
	var fila = []

	for d in [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		var q = origem + d

		if q.x < 0 or q.x >= n or q.y < 0:
			continue

		if g[q.y][q.x] in ["T", "D"] and not dist.has(q):
			dist[q] = 1
			fila.append(q)

	while fila.size() > 0:
		var p = fila.pop_front()

		if p.y == 0:
			return dist[p]

		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var q = p + d

			if q.x < 0 or q.x >= n or q.y < 0 or q.y >= n:
				continue

			if not (g[q.y][q.x] in ["T", "D"]) or dist.has(q):
				continue

			dist[q] = dist[p] + 1
			fila.append(q)

	return -1


func revelar_minas():
	for linha in celulas:
		for c in linha:
			if c.eh_mina():
				c.mostrar_mina()
