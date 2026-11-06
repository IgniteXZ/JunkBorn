extends Node2D


@export var musica: AudioStream



func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)
		
		
