extends Node2D

signal fechar_coleta

@export var lixo_scene: PackedScene
@export var lista_de_lixos: Array[LixoData] = []

# NOVO: Variável para controlar a quantidade no Inspector
@export var quantidade_lixos: int = 67 

@export var limite_minimo: Vector2 = Vector2(30, 100)
@export var limite_maximo: Vector2 = Vector2(1050, 700)

@onready var caixa_dialogo: Control = $DialogoColeta/CaixaDialogo
@onready var texto_dialogo: RichTextLabel = $DialogoColeta/CaixaDialogo/MargemDialogo/HBoxDialogo/TextoDialogo
@onready var dialogo_coleta: CanvasLayer = $DialogoColeta

func _ready() -> void:
	randomize()
	dialogo_coleta.hide()
	
	# Spawna a quantidade definida
	for i in range(quantidade_lixos):
		spawnar_lixo()

# NOVO: Função para o botão chamar
func randomizar_lixos() -> void:
	# 1. Limpa todos os lixos que estão na tela
	for child in get_children():
		if child.has_method("configurar"): # Só deleta o que for lixo
			child.queue_free()
			
	# 2. Espera um tiquinho (0.05 segundos) para o Godot deletar com segurança e spawna de novo
	await get_tree().create_timer(0.05).timeout
	
	for i in range(quantidade_lixos):
		spawnar_lixo()

func spawnar_lixo() -> void:
	if lista_de_lixos.is_empty() or not lixo_scene:
		print("ERRO: Configure a lixo_scene e a lista_de_lixos no Inspector!")
		return
	
	var novo_lixo_node = lixo_scene.instantiate()
	var lixo_aleatorio: LixoData = lista_de_lixos.pick_random()
	
	var pos_x = randf_range(limite_minimo.x, limite_maximo.x)
	var pos_y = randf_range(limite_minimo.y, limite_maximo.y)
	novo_lixo_node.global_position = Vector2(pos_x, pos_y)
	
	add_child(novo_lixo_node)
	novo_lixo_node.configurar(lixo_aleatorio, caixa_dialogo, texto_dialogo)


func _on_button_pressed() -> void:
	randomizar_lixos()
