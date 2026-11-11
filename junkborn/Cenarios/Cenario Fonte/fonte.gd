
extends Node2D

@export var musica: AudioStream

func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)


func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	pass
