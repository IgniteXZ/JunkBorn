extends Node2D

@export var lixo_scene: PackedScene # Arraste a cena do Lixo (com a Area2D) para esta variável no Inspector
@export var lista_de_lixos: Array[LixoData] = [] # Adicione os Resources de lixo criados no Inspector

# Define os limites manuais da área do chão onde o lixo pode nascer
@export var limite_minimo: Vector2 = Vector2(30, 100) # X inicial (esquerda), Y inicial (início do chão)
@export var limite_maximo: Vector2 = Vector2(1050, 700) # X final (direita), Y final (rodapé da tela)

func _ready() -> void:
	randomize()
	for i in range(5):
		spawnar_lixo()

func spawnar_lixo() -> void:
	if lista_de_lixos.is_empty() or not lixo_scene:
		print("Certifique-se de configurar a lixo_scene e adicionar itens na lista_de_lixos!")
		return
	
	# Instancia o objeto do lixo
	var novo_lixo_node = lixo_scene.instantiate()
	
	# Escolhe um tipo de lixo aleatório da lista
	var lixo_aleatorio: LixoData = lista_de_lixos.pick_random()
	
	# Posição aleatória dentro dos limites do chão configurados no Inspector
	var pos_x = randf_range(limite_minimo.x, limite_maximo.x)
	var pos_y = randf_range(limite_minimo.y, limite_maximo.y)
	novo_lixo_node.global_position = Vector2(pos_x, pos_y)
	
	# Adiciona à cena e passa os dados
	add_child(novo_lixo_node)
	novo_lixo_node.configurar(lixo_aleatorio)
