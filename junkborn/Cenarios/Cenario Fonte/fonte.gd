
extends Node2D

@export var musica: AudioStream

func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)


func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	pass
	
		
		

func _process(delta: float) -> void:
	
	if not Global.DesligarMusica and Musica:
		MusicaFonte.volume_db = -80.0
		var tween = create_tween()
		tween.tween_property(MusicaFonte, "volume_db", 0.0, 2.0)
		Musica = false
		
		
	elif Global.DesligarMusica and not Musica:
		Musica = true
		MusicaFonte.volume_db = -80.0
		


func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
