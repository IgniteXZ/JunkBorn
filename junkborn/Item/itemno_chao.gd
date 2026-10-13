extends Area2D

@export var dados_item: ItemData # Aqui você arrasta o arquivo .tres do item específico direto no Inspetor!
@export var labelinteragir: Label

var perto: bool = false
var canvass: CanvasLayer = null

func _ready() -> void:
	# Validação de segurança se o recurso foi preenchido
	if not dados_item:
		queue_free()
		return

	# Se o item já foi coletado antes, remove ele do mapa imediatamente
	if Global.itens_coletados.has(dados_item.id_item_mapa):
		queue_free()
		return
		
	# Atribui a textura automaticamente com base no Recurso escolhido
	if has_node("Sprite2D"):
		$Sprite2D.texture = dados_item.textura
		
	if labelinteragir:
		labelinteragir.visible = false

func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		if canvass == null:
			return

		# Tenta adicionar o item usando os dados do Recurso
		if canvass.add_item_inventory(dados_item.id, dados_item.textura):
			
			if not Global.itens_coletados.has(dados_item.id_item_mapa):
				Global.itens_coletados.append(dados_item.id_item_mapa)
			
			# Aqui você pode disparar missões específicas do item se ele possuir, ou geral
			# Exemplo: se o item tiver missões vinculadas no futuro
			
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
