extends Node2D

@export var musica: AudioStream

# O drone aparece em intervalos aleatórios entre 6 e 7 segundos.
@export_range(6.0, 7.0, 0.1) var intervalo_minimo_drone: float = 6.0
@export_range(6.0, 17.0, 0.1) var intervalo_maximo_drone: float = 7.0

var drone_scene: PackedScene = preload("res://Inimigo/Drone/drone.tscn")


func _ready() -> void:

	AudioManager.tocar_musica(musica)
	randomize()
	_spawn_drone_periodicamente()


func _spawn_drone_periodicamente() -> void:
	while is_inside_tree():
		var intervalo := randf_range(intervalo_minimo_drone, intervalo_maximo_drone)
		await get_tree().create_timer(intervalo).timeout

		if not is_inside_tree():
			return

		_spawn_drone()


func _spawn_drone() -> void:
	var jogador := get_tree().get_first_node_in_group("player")
	if jogador == null:
		push_warning("Drone não apareceu: jogador não encontrado no grupo 'player'.")
		return

	var drone := drone_scene.instantiate() as Node2D
	if drone == null:
		push_error("Não foi possível instanciar res://Inimigo/Drone/drone.tscn.")
		return

	add_child(drone)

	# Faz o drone surgir ao redor do jogador, próximo à borda da área visível.
	var angulo := randf_range(0.0, TAU)
	var distancia := randf_range(145.0, 165.0)
	drone.global_position = jogador.global_position + Vector2.RIGHT.rotated(angulo) * distancia
	Global.cidade_atual = 5

