extends Area2D

var perto: bool = false
var player: Area2D = null

func _ready() -> void:
	# Garante que os sinais estão conectados (caso não estejam pelo editor)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)

func _physics_process(_delta: float) -> void:
	if perto:
		perto = false  # evita chamar a troca de cena várias vezes
		get_tree().change_scene_to_file("res://Cutsenes/CutsceneTopo.tscn")

func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area
	print("entrei")

func _on_area_exited(area: Area2D) -> void:
	if area == player:
		perto = false
		player = null
