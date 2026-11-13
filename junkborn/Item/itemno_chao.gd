extends Area2D

@export var dados_item: ItemData
@export var labelinteragir: Label
@export var pagina_id: String = ""

var perto: bool = false
var canvass: CanvasLayer = null

var id_inventario: int
var id_coleta: Variant = null


func _ready() -> void:
	if not dados_item:
		queue_free()
		return

	# Identifica qual sistema de itens está sendo utilizado
	if dados_item is ItemData:
		id_inventario = dados_item.id
		if dados_item.id_item_mapa != "":
			id_coleta = dados_item.id_item_mapa
	else:
		push_error("Tipo de item não reconhecido!")
		return

	# Remove do mapa se já foi coletado
	if id_coleta != null and Global.itens_coletados.has(id_coleta):
		queue_free()
		return

	# Define a textura
	if has_node("Sprite2D"):
		$Sprite2D.texture = dados_item.textura

	if labelinteragir:
		labelinteragir.visible = false


func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		if not is_instance_valid(canvass):
			return

		# Adiciona o item ao inventário (4º argumento = o RECURSO inteiro)
		if canvass.add_item_inventory(
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


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
