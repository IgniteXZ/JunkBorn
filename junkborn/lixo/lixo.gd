extends Area2D

var dados: LixoData

@export var sprite: Sprite2D
@onready var control_tooltip: Control = $ControlLixo

func _ready() -> void:
	# Configura o Control para deixar os cliques de mouse passarem para a Area2D
	if control_tooltip:
		control_tooltip.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Conecta os sinais da Area2D para detectar entrada/saída do mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if dados:
		_atualizar_item()
		


func configurar(novo_lixo: LixoData) -> void:
	dados = novo_lixo
	_atualizar_item()

func _atualizar_item() -> void:
	if not dados:
		return
		
	# Atualiza a textura
	if sprite and dados.textura:
		sprite.texture = dados.textura
		
	# Configura o texto do tooltip no nó Control
	if control_tooltip:
		control_tooltip.tooltip_text = dados.nome + "\n" + dados.descricao

func _on_mouse_entered() -> void:
	
	if dados:
		print("--- LIXO ENCONTRADO ---")
		print("Nome: ", dados.nome)
		print("Tipo: ", dados.tipoDeLixo)
		print("Descrição: ", dados.descricao)

func _on_mouse_exited() -> void:
	print("67")
	
	

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Detecta o clique com o botão esquerdo sobre a Area2D
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		coletar_lixo()

func coletar_lixo() -> void:
	if dados and dados.Coletavel:
		var textura = dados.textura if dados.textura else sprite.texture
		
		var canvas = get_tree().root.find_child("ui_canvas", true, false)
		if canvas:
			canvas.add_item_inventory(textura)
		
		queue_free()
