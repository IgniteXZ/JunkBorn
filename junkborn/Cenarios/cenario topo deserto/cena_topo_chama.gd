extends Area2D

var _iniciando: bool = false

func _ready() -> void:
	monitoring = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _iniciar_cutscene() -> void:
	if _iniciando:
		return
	_iniciando = true
	
	get_tree().change_scene_to_file("res://Cutsenes/CutsceneTopo.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_iniciar_cutscene()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Interagir" and area.get_parent() != null and area.get_parent().is_in_group("player"):
		_iniciar_cutscene()
