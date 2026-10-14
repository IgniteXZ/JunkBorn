extends Node2D


@export var MusicaFonte: AudioStreamPlayer
var Musica: bool = true


func _ready() -> void:
	Global.cidade_atual = 0
	MusicaFonte.play()
	if not Global.DesligarMusica:
		MusicaFonte.volume_db = -80.0
		var tween = create_tween()
		tween.tween_property(MusicaFonte, "volume_db", 0.0, 3.0)
	elif Global.DesligarMusica:
		MusicaFonte.volume_db = -80.0
		
		
func _process(delta: float) -> void:
	
	if not Global.DesligarMusica and Musica:
		MusicaFonte.volume_db = -80.0
		var tween = create_tween()
		tween.tween_property(MusicaFonte, "volume_db", 0.0, 2.0)
		Musica = false
		
		
	elif Global.DesligarMusica and not Musica:
		Musica = true
		MusicaFonte.volume_db = -80.0
		
