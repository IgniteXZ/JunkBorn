extends Node

#mapa cidade atual
var cidade_atual : int = 0

#itens
var itens: Array = []
var itens_coletados: Array = []

# fluxo do jogo
var eventos: Dictionary = {}
var spawn_destino: String = ""

func trocar_cena(caminho: String, spawn: String) -> void:
	spawn_destino = spawn
	get_tree().change_scene_to_file(caminho)

func aplicar_spawn(player: Node2D) -> void:
	if spawn_destino == "":
		print("Nenhum spawn definido.")
		return

	print("Tentando usar spawn: ", spawn_destino)

	var cena_atual := get_tree().current_scene
	var spawn := cena_atual.get_node_or_null(spawn_destino) as Marker2D

	if spawn != null:
		print("Spawn encontrado!")
		print("Posição do spawn: ", spawn.global_position)
		player.global_position = spawn.global_position
	else:
		print("Spawn NÃO encontrado: ", spawn_destino)

	spawn_destino = ""
