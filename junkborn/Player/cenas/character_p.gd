extends Node2D
@export var mandacaru: CharacterBody2D
@export var npc: CharacterBody2D
@onready var Player = $"y-sort/Character"
@export var musica: AudioStream

var _npcs_realocados: bool = false

func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)
	_verificar_realocacao_npcs()

	if not Global.eventos.get("intro_vila", false):
		Player.process_mode = Node.PROCESS_MODE_DISABLED
		await TelaAto.aguardar()
		start_dialog()


func _process(_delta: float) -> void:
	# A variavel pode mudar enquanto a Vila ainda esta carregada.
	if not _npcs_realocados:
		_verificar_realocacao_npcs()


func _verificar_realocacao_npcs() -> void:
	if _npcs_realocados or Dialogic.VAR.deserto_liberado != true:
		return

	_npcs_realocados = true
	for personagem in [mandacaru, npc]:
		if not is_instance_valid(personagem):
			continue
		# Ocultar Sprite2D nao desliga a colisao do CharacterBody2D.
		personagem.hide()
		personagem.collision_layer = 0
		personagem.collision_mask = 0
		for forma in personagem.find_children("*", "CollisionShape2D", true, false):
			forma.set_deferred("disabled", true)
		personagem.queue_free()


func start_dialog():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("filomenoChegaVila")
	Player.process_mode = Node.PROCESS_MODE_DISABLED

func _on_timeline_ended():
	Global.eventos["intro_vila"] = true
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	Player.process_mode = Node.PROCESS_MODE_INHERIT
	Tutorial.mostrar("andar", "<move_up><move_left><move_down><move_right> ou as setas|para andar", "move_left move_right move_up move_down")
