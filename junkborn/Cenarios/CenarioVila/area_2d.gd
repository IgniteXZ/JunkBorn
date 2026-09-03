extends Area2D
var perto: bool = false
var player: Area2D = null

@export var labelinteragir: Label



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		print("gonnei")
		get_tree().change_scene_to_file("res://Deserto1.tscn")


func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area

	labelinteragir.visible = true

	


func _on_area_exited(area: Area2D) -> void:
	perto = false
	player = null

	labelinteragir.visible = false
