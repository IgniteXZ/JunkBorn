extends Node2D

@export var musica: AudioStream
@onready var barreira_deserto2: CollisionShape2D = $StaticBody2D2/CollisionShape2D2
@onready var aviso_deserto2: Area2D = $Area2D
var _estado_liberacao_deserto2: bool = false

func _ready() -> void:
	Global.cidade_atual = 1
	AudioManager.tocar_musica(musica)
	_atualizar_bloqueio_deserto2(true)

func _process(_delta: float) -> void:
	# Mantem a colisao sincronizada se a flag mudar sem recarregar a cena.
	_atualizar_bloqueio_deserto2()

func _atualizar_bloqueio_deserto2(forcar: bool = false) -> void:
	var liberado: bool = Dialogic.VAR.get_variable("podeSairFonte", false)
	if not forcar and liberado == _estado_liberacao_deserto2:
		return
	_estado_liberacao_deserto2 = liberado

	# Esta e a colisao da passagem bloqueada, nao as paredes do mapa.
	if is_instance_valid(barreira_deserto2):
		barreira_deserto2.set_deferred("disabled", liberado)

	# Desativa o dialogo "caminhoerrado" quando ja pode atravessar.
	if is_instance_valid(aviso_deserto2):
		aviso_deserto2.set_deferred("monitoring", not liberado)
