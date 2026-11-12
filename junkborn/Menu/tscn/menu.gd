extends Control

@export var musica: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.tocar_musica(musica)
