extends Node2D

@export var musica: AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.tocar_musica(musica)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
