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
	
	await Transicao.fade_out()
	
	get_tree().change_scene_to_file(caminho)
	await get_tree().scene_changed
	
	await get_tree().process_frame
	
	await Transicao.fade_in()

func aplicar_spawn(player: Node2D) -> void:
	if spawn_destino == "":
		return

	var cena_atual := get_tree().current_scene
	var spawn := cena_atual.get_node_or_null(spawn_destino) as Marker2D

	if spawn != null:
		player.global_position = spawn.global_position

	spawn_destino = ""
