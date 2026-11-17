extends Area2D

@export var planta_scene: PackedScene
@export var label_interagir: Label
@export var raio_espalhar: float = 30.0  # Mantido por compatibilidade com o Inspector.

# Uma posição diferente para cada semente evita plantas sobrepostas.
const POSICOES: Dictionary = {
	"fonte_semente_1": Vector2(-22, -12),
	"deserto1_semente2": Vector2(-5, -12),
	"deserto2_semente5": Vector2(5, -3),
	"mina_semente3": Vector2(-17, 15),
	"pantano_semente_4": Vector2(17, 15)
}
const CENA_PLANTA: PackedScene = preload("res://Minigames/PlantarSemente/planta_cultivada.tscn")

var perto: bool = false


func _ready() -> void:
	Global.TerminouOminiGame = true
	Global.plantas_plantadas = POSICOES.duplicate()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label_interagir:
		label_interagir.visible = false
		
	_restaurar_plantas()


func _process(_delta: float) -> void:
	# A missão pode ser ativada enquanto o jogador já está dentro da área.
	if perto:
		_atualizar_aviso()
	if perto and Global.TerminouOminiGame and Input.is_action_just_pressed("Interagir"):
		if Dialogic.current_timeline == null:
			plantar_sementes()


func _exit_tree() -> void:
	# Evita disparar a fala da plantação depois de trocar de cenário.
	Global.sair_area_plantacao()


func _eh_player(body: Node) -> bool:
	return body is CharacterBody2D and body.has_signal("PassarCanvas")


func _on_body_entered(body: Node2D) -> void:
	if _eh_player(body):
		perto = true
		Global.entrar_area_plantacao()
		_atualizar_aviso()


func _on_body_exited(body: Node2D) -> void:
	if _eh_player(body):
		perto = false
		Global.sair_area_plantacao()
		_atualizar_aviso()


func _atualizar_aviso() -> void:
	if label_interagir:
		label_interagir.visible = (perto and Global.TerminouOminiGame
			and Global.missao_ativa("plantar5sementes")
			and Global.plantas_plantadas.size() < 5)


func _achar_inventario() -> Node:
	return get_tree().get_first_node_in_group("inventario")


func _cena_para_semente(dados: ItemData) -> PackedScene:
	if dados.planta_scene != null:
		return dados.planta_scene
	if planta_scene != null:
		return planta_scene
	return CENA_PLANTA


func _instanciar_planta(cena: PackedScene, id_semente: String) -> Node2D:
	if cena == null:
		return null
	var instancia: Node = cena.instantiate()
	if not (instancia is Node2D):
		push_error("A cena da planta não possui raiz Node2D: " + id_semente)
		if instancia != null:
			instancia.free()
		return null
	instancia.set("especie", id_semente)
	return instancia as Node2D


func _inserir_planta(planta: Node2D, posicao_local: Vector2) -> void:
	# Mesmo YSort do jogador, para as plantas respeitarem a profundidade da cena.
	var camada: Node = get_parent().get_node_or_null("y-sort")
	if camada == null:
		camada = get_parent()
	camada.add_child(planta)
	planta.global_position = to_global(posicao_local)


func _restaurar_plantas() -> void:
	# Global permanece vivo entre mudanças de cena.
	for id_variant in Global.plantas_plantadas.keys():
		var id_semente: String = str(id_variant)
		if not POSICOES.has(id_semente):
			continue
		var planta := _instanciar_planta(CENA_PLANTA, id_semente)
		if planta != null:
			var posicao: Vector2 = Global.plantas_plantadas[id_semente]
			_inserir_planta(planta, posicao)
	_atualizar_aviso()


func plantar_sementes() -> void:
	# Impede plantar parcialmente antes da fase correta da história.
	if not Global.TerminouOminiGame or not Global.missao_ativa("plantar5sementes"):
		return
	var canvas := _achar_inventario()
	if canvas == null or not canvas.has_method("listar_sementes_para_plantio") or not canvas.has_method("consumir_sementes_plantio"):
		push_error("Plantio: inventário indisponível ou desatualizado.")
		return

	# 1. Consulta não destrutiva: nenhuma semente sai do inventário ainda.
	var sementes: Array = canvas.listar_sementes_para_plantio(Global.plantas_plantadas)
	if sementes.is_empty():
		print("[PLANTIO] Nenhuma semente disponível para plantar.")
		return

	# 2. Cria todas as plantas ANTES de alterar o inventário.
	var preparadas: Array = []
	var ids: Array = []
	for entrada in sementes:
		var dados: ItemData = entrada["dados"]
		var id_semente: String = entrada["id"]
		var planta := _instanciar_planta(_cena_para_semente(dados), id_semente)
		if planta == null:
			for item in preparadas:
				(item["planta"] as Node).free()
			push_error("Plantio cancelado; nenhuma semente foi consumida.")
			return
		preparadas.append({"id": id_semente, "planta": planta})
		ids.append(id_semente)

	# 3. Só agora retira uma unidade de cada semente, de modo atômico.
	if not canvas.consumir_sementes_plantio(ids):
		for item in preparadas:
			(item["planta"] as Node).free()
		push_warning("Plantio cancelado: o inventário mudou durante a interação.")
		return

	# 4. Registra a espécie e a posição para manter as plantas entre cenas.
	for item in preparadas:
		var id_semente: String = item["id"]
		var posicao: Vector2 = POSICOES[id_semente]
		Global.plantas_plantadas[id_semente] = posicao
		_inserir_planta(item["planta"] as Node2D, posicao)

	var total: int = Global.plantas_plantadas.size()
	Global.plantio_atualizado.emit(total)
	print("[PLANTIO] Plantou %d semente(s); total: %d/5." % [preparadas.size(), total])
	_atualizar_aviso()
