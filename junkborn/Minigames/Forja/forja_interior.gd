extends Node2D

@export var mandacaru: StaticBody2D
@export var npc: StaticBody2D
@export var musica: AudioStream

func _ready() -> void:
	Global.cidade_atual = 3
	AudioManager.tocar_musica(musica)

	var npcs_presentes: bool = Dialogic.VAR.deserto_liberado == true
	_configurar_npc(mandacaru, npcs_presentes)
	_configurar_npc(npc, npcs_presentes)

	if npcs_presentes:
		mandacaru.position = Vector2(-673, 379)
		npc.position = Vector2(-566, 514)


func _configurar_npc(personagem: StaticBody2D, ativo: bool) -> void:
	if not is_instance_valid(personagem):
		return

	personagem.visible = ativo
	# O NPC escondido nao pode deixar uma barreira invisivel.
	personagem.collision_layer = 1 if ativo else 0
	personagem.collision_mask = 1 if ativo else 0

	# A Area2D do dialogo continua independente da colisao fisica.
	for area in personagem.find_children("*", "Area2D", true, false):
		area.monitoring = ativo
		area.monitorable = ativo
