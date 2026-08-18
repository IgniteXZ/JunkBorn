extends Area2D

var dados: LixoData

@export var sprite: Sprite2D


func _ready() -> void:
	# Conecta os sinais da Area2D para detectar a entrada e saída do mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Atualiza a textura se os dados já tiverem sido atribuídos
	if dados and dados.textura:
		sprite.texture = dados.textura

func configurar(novo_lixo: LixoData) -> void:
	dados = novo_lixo
	if sprite and dados.textura:
		sprite.texture = dados.textura

func _on_mouse_entered() -> void:
	if dados:
		print("--- LIXO ENCONTRADO ---")
		print("Nome: ", dados.nome)
		print("Descrição: ", dados.descricao)

func _on_mouse_exited() -> void:
	# Aqui você poderá esconder a interface de tooltip no futuro
	pass

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Detecta o clique com o botão esquerdo do mouse sobre a área
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		coletar_lixo()

func coletar_lixo() -> void:
	if dados.Coletavel:
		print("Iniciando cutscene para o lixo: ", dados.nome)
		# No futuro, chame o gerenciador de cutscenes aqui
		queue_free() # Remove o lixo coletado da tela
	
