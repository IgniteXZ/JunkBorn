
extends Node2D

@export var musica: AudioStream

func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)
	

func _process(_delta: float) -> void:
	# Verifica se a semente foi coletada
	if not Global.itens_coletados.has("fonte_semente_1"):
		return

	# Impede repetir o diálogo
	if Global.eventos.get("dialogo_semente_1", false):
		return

	Global.eventos["dialogo_semente_1"] = true
	Dialogic.start("dialogoSemente1")





func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	pass


func coletou_semente_1() -> bool:
	return Global.itens_coletados.has("fonte_semente_1")
