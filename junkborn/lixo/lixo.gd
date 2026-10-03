extends Area2D

var dados: LixoData

@export var sprite: Sprite2D
@onready var control_tooltip: Control = $ControlLixo

var caixa_dialogo: Control
var texto_dialogo: RichTextLabel


func _ready() -> void:
	if control_tooltip:
		control_tooltip.mouse_filter = Control.MOUSE_FILTER_PASS
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if dados:
		_atualizar_item()


func configurar(
	novo_lixo: LixoData,
	nova_caixa_dialogo: Control,
	novo_texto_dialogo: RichTextLabel
) -> void:
	dados = novo_lixo
	caixa_dialogo = nova_caixa_dialogo
	texto_dialogo = novo_texto_dialogo
	_atualizar_item()


func _atualizar_item() -> void:
	if not dados:
		return
	
	if sprite and dados.textura:
		sprite.texture = dados.textura
	
	if control_tooltip:
		control_tooltip.tooltip_text = ""


func _on_mouse_entered() -> void:
	if dados and caixa_dialogo and texto_dialogo:
		texto_dialogo.text = dados.nome + "\n\n" + dados.descricao
		texto_dialogo.visible_characters = 0
		caixa_dialogo.get_parent().show()
		
		var tween := create_tween()
		tween.tween_property(
			texto_dialogo,
			"visible_characters",
			texto_dialogo.get_total_character_count(),
			2.0
		)


func _on_mouse_exited() -> void:
	if caixa_dialogo:
		caixa_dialogo.get_parent().hide()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		coletar_lixo()


func coletar_lixo() -> void:
	if dados and dados.Coletavel:
		var textura = dados.textura if dados.textura else sprite.texture
		
		var canvas = get_tree().root.find_child("ui_canvas", true, false)
		if canvas:
			canvas.add_item_inventory(dados.item_id, textura)
		
		queue_free()
