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



func _parar_animacao() -> void:
	if texto_dialogo.has_meta("tween_texto"):
		var tween_anterior: Tween = texto_dialogo.get_meta("tween_texto")

		if tween_anterior and tween_anterior.is_valid():
			tween_anterior.kill()

		texto_dialogo.remove_meta("tween_texto")


func _on_mouse_entered() -> void:
	if not dados or not caixa_dialogo or not texto_dialogo:
		return

	# Cancela a animação anterior, mesmo que seja de outro lixo
	_parar_animacao()

	# Identifica qual lixo está mostrando o diálogo
	texto_dialogo.set_meta("lixo_ativo", get_instance_id())

	# Reinicia o texto do zero
	texto_dialogo.text = dados.nome + "\n\n" + dados.descricao
	texto_dialogo.visible_characters = 0

	caixa_dialogo.get_parent().show()

	# Velocidade constante: 40 caracteres por segundo
	var total = texto_dialogo.get_total_character_count()
	var duracao = total * 0.025

	if total > 0:
		var tween = get_tree().create_tween().bind_node(texto_dialogo)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(
			texto_dialogo,
			"visible_characters",
			total,
			duracao
		)

		texto_dialogo.set_meta("tween_texto", tween)


func _on_mouse_exited() -> void:
	_fechar_dialogo()


func _fechar_dialogo() -> void:
	if not caixa_dialogo or not texto_dialogo:
		return

	# Só fecha se este lixo for o que está mostrando o texto
	if texto_dialogo.get_meta("lixo_ativo", 0) != get_instance_id():
		return

	_parar_animacao()
	texto_dialogo.remove_meta("lixo_ativo")
	caixa_dialogo.get_parent().hide()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		coletar_lixo()

func coletar_lixo() -> void:
	if dados and dados.Coletavel:
		var textura = dados.textura if dados.textura else sprite.texture

		var canvas = get_tree().root.find_child("ui_canvas", true, false)
		if canvas:
			canvas.add_item_inventory(dados.item_id, textura, dados.nome)

		if caixa_dialogo:
			caixa_dialogo.get_parent().hide()
		_fechar_dialogo()
		queue_free()
