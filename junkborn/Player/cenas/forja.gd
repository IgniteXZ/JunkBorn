extends Area2D

var perto: bool = false


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		print("Aperte E para entrar na forja")
		Global.trocar_cena(
		 "res://Minigames/Forja/forjaInterior.tscn",
		 "spawnsForja/entradaForja"
		)



func _on_area_entered(_area: Area2D) -> void:
	perto = true



func _on_area_exited(_area: Area2D) -> void:
	perto = false
