extends Node2D


@export var musica: AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.cidade_atual = 1
	AudioManager.tocar_musica(musica)
	
