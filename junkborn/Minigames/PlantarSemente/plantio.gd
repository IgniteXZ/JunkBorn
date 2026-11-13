extends Area2D

@export var planta_scene: PackedScene  # fallback, usado se a semente não tiver planta_scene
@export var label_interagir: Label     # opcional: aviso "Aperte E"
@export var raio_espalhar: float = 30.0

var perto: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label_interagir:
		label_interagir.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interagir"):
		print("[AREA] E apertado | perto: ", perto, " | TerminouOminiGame: ", Global.TerminouOminiGame)
	if perto and Input.is_action_just_pressed("Interagir") and Global.TerminouOminiGame:
		plantar_sementes()


func _eh_player(body: Node) -> bool:
	return body is CharacterBody2D and body.has_signal("PassarCanvas")


func _on_body_entered(body: Node2D) -> void:
	print("[AREA] body entrou: ", body.name, " | eh_player: ", _eh_player(body))
	if _eh_player(body):
		perto = true
		if label_interagir:
			label_interagir.visible = true





func _on_body_exited(body: Node2D) -> void:
	if _eh_player(body):
		perto = false
		if label_interagir:
			label_interagir.visible = false


func _achar_inventario() -> Node:
	var canvas := get_tree().get_first_node_in_group("inventario")
	if canvas == null:
		canvas = get_tree().root.find_child("ui_canvas", true, false)
	return canvas


func plantar_sementes() -> void:
	var canvas := _achar_inventario()
	if canvas == null or not canvas.has_method("remover_todas_as_sementes"):
		push_error("Inventário não encontrado ou sem 'remover_todas_as_sementes'.")
		return

	var sementes: Array = canvas.remover_todas_as_sementes()
	if sementes.is_empty():
		print("Você não tem sementes no inventário!")
		return

	var plantadas := 0
	for dados in sementes:
		var cena: PackedScene = dados.planta_scene if dados.planta_scene != null else planta_scene
		if cena == null:
			push_error("A semente '%s' não tem planta_scene e a área também não." % dados.nome)
			continue

		var pos := global_position + Vector2(
			randf_range(-raio_espalhar, raio_espalhar),
			randf_range(-raio_espalhar, raio_espalhar)
		)
		var nova_planta = cena.instantiate()
		get_parent().add_child(nova_planta)
		nova_planta.global_position = pos
		plantadas += 1

	print("Plantou ", plantadas, " sementes!")
