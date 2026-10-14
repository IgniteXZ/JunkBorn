extends Node2D


@export var MusicaFonte: AudioStreamPlayer

func _ready() -> void:
	Global.cidade_atual = 0
	
	MusicaFonte.volume_db = -80.0
	MusicaFonte.play()
	var tween = create_tween()
	tween.tween_property(MusicaFonte, "volume_db", 0.0, 3.0)
	
