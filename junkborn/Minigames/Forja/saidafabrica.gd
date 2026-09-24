extends Area2D

var perto: bool = false


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		print("Aperte E para entrar na forja")
		get_tree().change_scene_to_file("res://Cenarios/CenarioVila/characterP.tscn")
		
		
		

func _on_area_entered(area: Area2D) -> void:
	perto = true


func _on_area_exited(area: Area2D) -> void:
	perto = false
