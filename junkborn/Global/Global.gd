extends Node

#outros
var chamarJangada : bool = false


#mapa cidade atual
var cidade_atual : int = 0

#itens
var itens: Array = []
var itens_coletados: Array = []
var nomes_itens: Dictionary = {}

# fluxo do jogo
var eventos: Dictionary = {}
var spawn_destino: String = ""
var esta_coleta: bool = false
var paginas_coletadas: Dictionary = {}

var DesligarMusica: bool = false

var TerminouOminiGame: bool = false
# Chave: ID único de coleta da semente; valor: deslocamento local no terreno.
# Este dicionário persiste enquanto o jogo está aberto, inclusive entre cenas.
var plantas_plantadas: Dictionary = {}
signal plantio_atualizado(quantidade: int)

# Progressão da história: a sexta semente (Verbácio) nunca é obtida.
const SEMENTES_ENCONTRAVEIS: Array[String] = [
	"fonte_semente_1",
	"deserto1_semente2",
	"deserto2_semente5",
	"mina_semente3",
    "pantano_semente_4"
]

var _dialogo_cinco_iniciado: bool = false
var _dialogo_cinco_terminado: bool = false
var _esperar_visita_plantacao: bool = false
var _perto_da_plantacao: bool = false
var _dialogo_area_iniciado: bool = false
var _dialogo_area_terminado: bool = false
var _missao_avo_iniciada: bool = false


func _ready() -> void:
	plantio_atualizado.connect(_ao_plantio_atualizado)


func _process(_delta: float) -> void:
	# Recuperação defensiva: permite continuar se o sinal já foi emitido.
	if plantas_plantadas.size() >= SEMENTES_ENCONTRAVEIS.size() and not _missao_avo_iniciada:
		_ao_plantio_atualizado(plantas_plantadas.size())

	if Dialogic.current_timeline != null:
		return
	if esta_coleta or not get_tree().get_nodes_in_group("minigame_aberto").is_empty():
		return

	# Só dispara ao ter as CINCO espécies diferentes no inventário.
	if not _dialogo_cinco_iniciado and _tem_cinco_sementes_no_inventario():
		_dialogo_cinco_iniciado = true
		var inventario := get_tree().get_first_node_in_group("inventario")
		if inventario != null and inventario.has_method("fechar_interfaces_para_drone"):
			inventario.fechar_interfaces_para_drone()
		Dialogic.start("dialogoCincoSementes")
		return

	# Primeiro contato, apenas durante verplantacao; dispara uma única vez.
	if _perto_da_plantacao and not _dialogo_area_iniciado and missao_ativa("verplantacao") and TerminouOminiGame:
		_dialogo_area_iniciado = true
		Dialogic.start("dialogoAreaPlantacao")


func missao_ativa(id: String) -> bool:
	for missao in GerenciadorMissoes.missoes_ativas:
		if missao != null and missao.id_missao == id and not missao.concluida:
			return true
	return false


func _tem_cinco_sementes_no_inventario() -> bool:
	if not plantas_plantadas.is_empty():
		return false
	for id_semente in SEMENTES_ENCONTRAVEIS:
		if not itens_coletados.has(id_semente):
			return false
	var inventario := get_tree().get_first_node_in_group("inventario")
	if inventario == null or not inventario.has_method("listar_sementes_para_plantio"):
		return false
	return inventario.listar_sementes_para_plantio(plantas_plantadas).size() == SEMENTES_ENCONTRAVEIS.size()


# Executada no final do diálogo da quinta semente, não no começo.
func concluir_dialogo_cinco_sementes() -> void:
	if _dialogo_cinco_terminado:
		return
	_dialogo_cinco_terminado = true
	GerenciadorMissoes.completar_missao("buscarsementes")

	if TerminouOminiGame:
		_ativar_missao_plantar()
	else:
		# Primeiro precisa terminar os canos, visitar o terreno e conhecer a área.
		_esperar_visita_plantacao = true


func entrar_area_plantacao() -> void:
	_perto_da_plantacao = true


func sair_area_plantacao() -> void:
	_perto_da_plantacao = false


# Executada no fim da fala de descoberta do terreno.
func concluir_dialogo_area_plantacao() -> void:
	_dialogo_area_terminado = true
	if _esperar_visita_plantacao and _dialogo_cinco_terminado:
		_esperar_visita_plantacao = false
		_ativar_missao_plantar()


func _ativar_missao_plantar() -> void:
	if not _dialogo_cinco_terminado or not TerminouOminiGame:
		return
	if _esperar_visita_plantacao and not _dialogo_area_terminado:
		return
	if missao_ativa("plantar5sementes") or _missao_avo_iniciada:
		return
	GerenciadorMissoes.completar_missao("verplantacao")
	GerenciadorMissoes.iniciar("plantar5sementes")


func _ao_plantio_atualizado(quantidade: int) -> void:
	if quantidade < SEMENTES_ENCONTRAVEIS.size() or _missao_avo_iniciada:
		return
	_missao_avo_iniciada = true
	GerenciadorMissoes.completar_missao("plantar5sementes")
	GerenciadorMissoes.iniciar("falarcomavo")
	Dialogic.VAR.set_variable("conversarComAvo", true)


var drones_spawnados: Array = []

var dados_por_textura: Dictionary = {}
func fade() -> void:
	await Transicao.fade_out()
	await Transicao.fade_in()


func trocar_cena(caminho: String, spawn: String, titulo_ato: String = "") -> void:
	spawn_destino = spawn
	
	await Transicao.fade_out()
	
	
	get_tree().change_scene_to_file(caminho)
	await get_tree().scene_changed
	
	await get_tree().process_frame
	
	await Transicao.fade_in()

	# Usa a mesma tela de atos do prologo e do Ato 1, mas somente
	# na primeira transicao que solicitar este titulo (saida da Fonte).
	if titulo_ato != "":
		var chave_ato := "tela_ato_exibida:" + titulo_ato
		if not eventos.get(chave_ato, false):
			eventos[chave_ato] = true
			var jogador := get_tree().current_scene.find_child("Character", true, false)
			if jogador != null:
				jogador.set("pode_mover", false)
			await TelaAto.mostrar(titulo_ato)
			if is_instance_valid(jogador):
				jogador.set("pode_mover", true)


func trocarCenaSemSpawn(caminho: String) -> void:
	
	await Transicao.fade_out()
	
	get_tree().change_scene_to_file(caminho)
	await get_tree().scene_changed
	
	await get_tree().process_frame
	
	await Transicao.fade_in()

func aplicar_spawn(player: Node2D) -> void:
	if spawn_destino == "":
		return

	var cena_atual := get_tree().current_scene
	var spawn := cena_atual.get_node_or_null(spawn_destino) as Marker2D

	if spawn != null:
		player.global_position = spawn.global_position

	spawn_destino = ""
