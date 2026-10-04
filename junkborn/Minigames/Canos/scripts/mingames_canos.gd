extends Control

@onready var lbl_fase: Label = $cabecario/fase
@onready var lbl_tempo: Label = $cabecario/tempo
@onready var lbl_canos: Label = $cabecario/canos

# Uso de get_node_or_null para evitar erros de nó nulo caso a hierarquia mude
@onready var terra_map: TileMapLayer = get_node_or_null("../terra")
@onready var canos_map: TileMapLayer = get_node_or_null("../canos_minas")
@onready var agua_map: TileMapLayer = get_node_or_null("../agua")
@onready var timer_jogo: Timer = get_node_or_null("../Timer")

var lbl_mensagem: Label

const LARGURA: int = 8
const ALTURA: int = 8
const TILE_SIZE: int = 64

const TILE_TERRA_ID: int = 0
const TILE_CANO_RETO_ID: int = 0
const TILE_CANO_CURVA_ID: int = 1
const TILE_INICIO_ID: int = 2
const TILE_FIM_ID: int = 3
const TILE_MINA_ID: int = 5
const TILE_AGUA_ID: int = 0

const DIRECOES = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var fase_atual: int = 1
var canos_inventario: int = 30
var tempo_restante: float = 180.0
var agua_rodando: bool = false
var pos_minas: Array[Vector2i] = []
var pos_inicio: Vector2i = Vector2i(0, 0)
var pos_fim: Vector2i = Vector2i(7, 7)

func _ready() -> void:
	configurar_label_mensagem()

	if timer_jogo and not timer_jogo.timeout.is_connected(_on_timer_timeout):
		timer_jogo.timeout.connect(_on_timer_timeout)
		
	await get_tree().process_frame
	iniciar_fase(1)

func configurar_label_mensagem() -> void:
	if has_node("lbl_mensagem"):
		lbl_mensagem = $lbl_mensagem
	else:
		lbl_mensagem = Label.new()
		lbl_mensagem.name = "lbl_mensagem"
		add_child(lbl_mensagem)
	
	lbl_mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_mensagem.position = Vector2(400, 120)
	lbl_mensagem.size = Vector2(LARGURA * TILE_SIZE, ALTURA * TILE_SIZE)
	lbl_mensagem.add_theme_font_size_override("font_size", 36)

func iniciar_fase(fase: int) -> void:
	fase_atual = fase
	agua_rodando = false
	canos_inventario = 30
	
	if lbl_fase:
		lbl_fase.text = "Fase: " + str(fase_atual) + "/3"
	
	pos_minas.clear()
	
	if is_instance_valid(terra_map):
		terra_map.clear()
	if is_instance_valid(canos_map):
		canos_map.clear()
	if is_instance_valid(agua_map):
		agua_map.clear()
	
	var quantidade_minas: int = 3
	match fase_atual:
		1:
			tempo_restante = 180.0
			quantidade_minas = 3
		2:
			tempo_restante = 150.0
			quantidade_minas = 8
		3:
			tempo_restante = 120.0
			quantidade_minas = 14

	gerar_tabuleiro()
	gerar_posicoes_especiais()
	gerar_minas(quantidade_minas)
	atualizar_hud()
	iniciar_contagem_regressiva()

func gerar_tabuleiro() -> void:
	if not is_instance_valid(terra_map):
		return
	for x in range(LARGURA):
		for y in range(ALTURA):
			terra_map.set_cell(Vector2i(x, y), TILE_TERRA_ID, Vector2i(0, 0))

func gerar_posicoes_especiais() -> void:
	if not is_instance_valid(canos_map):
		return
	pos_inicio = Vector2i(0, randi() % ALTURA)
	pos_fim = Vector2i(LARGURA - 1, randi() % ALTURA)
	
	canos_map.set_cell(pos_inicio, TILE_INICIO_ID, Vector2i(0, 0))
	canos_map.set_cell(pos_fim, TILE_FIM_ID, Vector2i(0, 0))

func gerar_minas(quantidade: int) -> void:
	if not is_instance_valid(canos_map):
		return
	var minas_colocadas: int = 0
	
	while minas_colocadas < quantidade:
		var rx: int = randi() % LARGURA
		var ry: int = randi() % ALTURA
		var pos_sorteada: Vector2i = Vector2i(rx, ry)
		
		if not pos_sorteada in pos_minas and pos_sorteada != pos_inicio and pos_sorteada != pos_fim:
			pos_minas.append(pos_sorteada)
			canos_map.set_cell(pos_sorteada, TILE_MINA_ID, Vector2i(0, 0))
			minas_colocadas += 1

func iniciar_contagem_regressiva() -> void:
	lbl_mensagem.visible = true
	
	lbl_mensagem.text = "Iniciando em 3..."
	await get_tree().create_timer(1.0).timeout
	
	lbl_mensagem.text = "Iniciando em 2..."
	await get_tree().create_timer(1.0).timeout
	
	lbl_mensagem.text = "Iniciando em 1..."
	await get_tree().create_timer(1.0).timeout
	
	lbl_mensagem.text = "VALENDO!"
	await get_tree().create_timer(0.8).timeout
	lbl_mensagem.visible = false
	
	agua_rodando = true
	if is_instance_valid(timer_jogo):
		timer_jogo.start(1.0)

func _unhandled_input(event: InputEvent) -> void:
	if not agua_rodando or not is_instance_valid(canos_map):
		return

	if event is InputEventMouseButton and event.pressed:
		var pos_local = canos_map.get_local_mouse_position()
		var celula_clicada = canos_map.local_to_map(pos_local)

		if celula_clicada.x >= 0 and celula_clicada.x < LARGURA and celula_clicada.y >= 0 and celula_clicada.y < ALTURA:
			if event.button_index == MOUSE_BUTTON_LEFT:
				processar_clique_esquerdo(celula_clicada)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				processar_clique_direito(celula_clicada)

func processar_clique_esquerdo(pos: Vector2i) -> void:
	if pos in pos_minas:
		game_over("GAME OVER!\nClicou em uma mina! BOOM!")
		return

	if pos == pos_inicio or pos == pos_fim:
		return

	var tile_id = canos_map.get_cell_source_id(pos)
	
	if tile_id == -1:
		if canos_inventario <= 0:
			return
		canos_map.set_cell(pos, TILE_CANO_RETO_ID, Vector2i(0, 0))
		canos_inventario -= 1
		atualizar_hud()
	elif tile_id == TILE_CANO_RETO_ID:
		canos_map.set_cell(pos, TILE_CANO_CURVA_ID, Vector2i(0, 0))
	elif tile_id == TILE_CANO_CURVA_ID:
		canos_map.set_cell(pos, TILE_CANO_RETO_ID, Vector2i(0, 0))

	verificar_conexao_agua()

func processar_clique_direito(pos: Vector2i) -> void:
	if pos == pos_inicio or pos == pos_fim or pos in pos_minas:
		return

	var tile_id = canos_map.get_cell_source_id(pos)
	if tile_id == TILE_CANO_RETO_ID or tile_id == TILE_CANO_CURVA_ID:
		var alt_atual = canos_map.get_cell_alternative_tile(pos)
		var proxima_alt = (alt_atual + 1) % 4
		canos_map.set_cell(pos, tile_id, Vector2i(0, 0), proxima_alt)
		
		verificar_conexao_agua()

# --- LÓGICA E ANIMAÇÃO DA ÁGUA ---

func verificar_conexao_agua() -> void:
	var caminho_completo: Array[Vector2i] = obter_caminho_conectado()
	
	if caminho_completo.size() > 0 and caminho_completo.back() == pos_fim:
		agua_rodando = false
		if is_instance_valid(timer_jogo):
			timer_jogo.stop()
		animar_fluxo_agua(caminho_completo)

func obter_caminho_conectado() -> Array[Vector2i]:
	var visitados: Array[Vector2i] = []
	var fila: Array = [[pos_inicio]]
	
	while fila.size() > 0:
		var caminho_generico = fila.pop_front()
		
		var caminho_atual: Array[Vector2i] = []
		caminho_atual.assign(caminho_generico)
		
		var no_atual = caminho_atual.back()
		
		if no_atual == pos_fim:
			return caminho_atual
			
		visitados.append(no_atual)
		
		for dir_idx in range(4):
			var vizinho = no_atual + DIRECOES[dir_idx]
			if vizinho.x >= 0 and vizinho.x < LARGURA and vizinho.y >= 0 and vizinho.y < ALTURA:
				if not vizinho in visitados:
					if conexao_valida(no_atual, vizinho, dir_idx):
						var novo_caminho: Array[Vector2i] = []
						novo_caminho.assign(caminho_atual)
						novo_caminho.append(vizinho)
						fila.append(novo_caminho)
	return []

func conexao_valida(de: Vector2i, para: Vector2i, direcao: int) -> bool:
	var tile_de = canos_map.get_cell_source_id(de)
	var tile_para = canos_map.get_cell_source_id(para)
	
	if tile_para == -1 or tile_para == TILE_MINA_ID:
		return false
		
	var saida_de = obter_conexoes_cano(tile_de, canos_map.get_cell_alternative_tile(de))
	var entrada_para = obter_conexoes_cano(tile_para, canos_map.get_cell_alternative_tile(para))
	
	var oposto = (direcao + 2) % 4
	return saida_de[direcao] and entrada_para[oposto]

func obter_conexoes_cano(tile_id: int, rotacao: int) -> Array[bool]:
	match tile_id:
		TILE_INICIO_ID:
			return [true, true, true, true]
		TILE_FIM_ID:
			return [true, true, true, true]
		TILE_CANO_RETO_ID:
			if rotacao % 2 == 0:
				return [false, true, false, true]
			else:
				return [true, false, true, false]
		TILE_CANO_CURVA_ID:
			match rotacao:
				0: return [true, true, false, false]
				1: return [false, true, true, false]
				2: return [false, false, true, true]
				3: return [true, false, false, true]
	return [false, false, false, false]

func animar_fluxo_agua(caminho: Array[Vector2i]) -> void:
	for pos in caminho:
		if is_instance_valid(agua_map):
			agua_map.set_cell(pos, TILE_AGUA_ID, Vector2i(0, 0))
		await get_tree().create_timer(0.2).timeout
		
	passar_de_fase()

func _on_timer_timeout() -> void:
	if not agua_rodando:
		return

	tempo_restante -= 1.0
	atualizar_hud()

	if tempo_restante <= 0:
		var caminho = obter_caminho_conectado()
		if caminho.size() == 0 or caminho.back() != pos_fim:
			game_over("GAME OVER!\nO tempo acabou e a água vazou!")
		else:
			agua_rodando = false
			if is_instance_valid(timer_jogo):
				timer_jogo.stop()
			animar_fluxo_agua(caminho)

func atualizar_hud() -> void:
	if lbl_canos:
		lbl_canos.text = "Canos: " + str(canos_inventario)
	
	if lbl_tempo:
		var minutos = int(tempo_restante) / 60
		var segundos = int(tempo_restante) % 60
		lbl_tempo.text = "Tempo: %02d:%02d" % [minutos, segundos]

func game_over(motivo: String) -> void:
	agua_rodando = false
	if is_instance_valid(timer_jogo):
		timer_jogo.stop()
	
	lbl_mensagem.text = motivo
	lbl_mensagem.visible = true
	
	await get_tree().create_timer(3.0).timeout
	fechar_minigame()

func passar_de_fase() -> void:
	if fase_atual < 3:
		lbl_mensagem.text = "Fase Concluída!\nAvançando..."
		lbl_mensagem.visible = true
		await get_tree().create_timer(2.0).timeout
		lbl_mensagem.visible = false
		iniciar_fase(fase_atual + 1)
	else:
		lbl_mensagem.text = "PARABÉNS!\nVocê venceu todas as 3 fases!"
		lbl_mensagem.visible = true
		await get_tree().create_timer(3.0).timeout
		fechar_minigame()

func fechar_minigame() -> void:
	queue_free()
