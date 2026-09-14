extends Area2D

var perto: bool = false
@export var mini_game_coleta: Node2D
@export var jogador: CharacterBody2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		print("Aperte E para entrar no minigame")
		mini_game_coleta.show()
		jogador.pode_mover = false
		
		
		
func _on_mini_game_coleta_fechar_coleta() -> void:
	mini_game_coleta.hide()
	jogador.pode_mover = true

func _on_area_entered(_area: Area2D) -> void:
	perto = true
	
	


func _on_area_exited(area: Area2D) -> void:
	perto = false
