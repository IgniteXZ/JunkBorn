extends Node2D

@export var musica: AudioStream
var drone = preload("res://Inimigo/Drone/drone.tscn")


func _ready() -> void:
	Global.cidade_atual = 7
	AudioManager.tocar_musica(musica)


func _process(_delta: float) -> void:
	# Verifica se a semente foi coletada
	if not coletou_semente_1():
		return

	# Impede repetir o diálogo
	if Global.eventos.get("dialogo_semente_1", false):
		return

	# Espera outro diálogo terminar
	if Dialogic.current_timeline != null:
		return

	Global.eventos["dialogo_semente_1"] = true
	Dialogic.start("dialogoSemente1")


func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	AudioManager.tocar_musica(musica)


func coletou_semente_1() -> bool:
	return Global.itens_coletados.has("fonte_semente_1")
