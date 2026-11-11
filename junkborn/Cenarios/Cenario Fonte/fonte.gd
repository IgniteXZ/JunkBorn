
extends Node2D

@export var musica: AudioStream
var drone = preload("res://Inimigo/Drone/drone.tscn")


func _ready() -> void:
	Global.cidade_atual = 0
	AudioManager.tocar_musica(musica)



func _on_dialogo_fonte_area_entered(area: Area2D) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	# Só para a música se o minigame NÃO estiver aberto
	AudioManager.parar_musica()


func _on_area_2d_area_exited(area: Area2D) -> void:
	# Só continua/retorna a música se o minigame NÃO estiver aberto
	AudioManager.Continuar_musica()
		
