extends Area2D

@export var drone_scene: PackedScene = preload("res://Inimigo/Drone/drone.tscn")
@export var id_spawn: String = ""   # opcional: se vazio, usa cena + nome do nó

var ativado: bool = false
var _id: String = ""


func _ready() -> void:
	_id = id_spawn
	if _id == "":
		_id = get_tree().current_scene.scene_file_path + "/" + str(name)

	# Já apareceu antes (mesmo trocando de cena): não cria de novo
	if Global.drones_spawnados.has(_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if ativado:
		return
	if not (body is CharacterBody2D and body.has_signal("PassarCanvas")):
		return

	ativado = true
	_spawnar.call_deferred()  # adiar: não dá para criar corpos físicos durante o callback da física


func _spawnar() -> void:
	Global.drones_spawnados.append(_id)

	for filho in get_children():
		if filho is Marker2D:
			var drone = drone_scene.instantiate()
			get_parent().add_child(drone)
			drone.global_position = filho.global_position

	queue_free()
