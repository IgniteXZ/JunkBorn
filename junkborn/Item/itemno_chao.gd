extends Area2D

@export var dados_item: ItemData
@export var labelinteragir: Label
@export var pagina_id: String = ""
# Opcional: id único DESTA cópia no mapa. Se vazio, usa o id_item_mapa do .tres
@export var id_coleta_proprio: String = ""

var perto: bool = false
var canvass: CanvasLayer = null

var id_inventario: int
var id_coleta: Variant = null


func _ready() -> void:
	if not dados_item:
		queue_free()
		return

	id_inventario = dados_item.id

	if id_coleta_proprio != "":
		id_coleta = id_coleta_proprio
	elif dados_item.id_item_mapa != "":
		id_coleta = dados_item.id_item_mapa

	# Remove do mapa se já foi coletado
	if id_coleta != null and Global.itens_coletados.has(id_coleta):
		queue_free()
		return

	# Conecta os sinais da própria área (funciona em cópias, sem duplicar conexão)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)

	if has_node("Sprite2D"):
		$Sprite2D.texture = dados_item.textura

	if labelinteragir:
		labelinteragir.visible = false


func _achar_canvas() -> CanvasLayer:
	if is_instance_valid(canvass):
		return canvass
	canvass = get_tree().get_first_node_in_group("inventario") as CanvasLayer
	return canvass


func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		var canvas := _achar_canvas()
		if canvas == null:
			push_warning("Item: inventário não encontrado (grupo 'inventario').")
			return

		# Adiciona o item ao inventário (4º argumento = o RECURSO inteiro)
		if canvas.add_item_inventory(
			id_inventario,
			dados_item.textura,
			dados_item.nome,
			dados_item
		):
			# Registra a coleta
			if id_coleta != null and not Global.itens_coletados.has(id_coleta):
				Global.itens_coletados.append(id_coleta)

			# Libera a página correspondente do livro
			if pagina_id != "":
				Global.paginas_coletadas[pagina_id] = true

			if labelinteragir:
				labelinteragir.visible = false

			queue_free()


func _on_area_entered(_area: Area2D) -> void:
	perto = true
	if labelinteragir:
		labelinteragir.visible = true


func _on_area_exited(_area: Area2D) -> void:
	perto = false
	if labelinteragir:
		labelinteragir.visible = false


# Mantido para compatibilidade com a conexão antiga (não é mais necessário)
func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
