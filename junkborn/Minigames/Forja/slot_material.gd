extends PanelContainer
class_name SlotMaterial

var textura_obrigatoria: Texture2D = null
var quantidade_obrigatoria: int = 0
var quantidade_acumulada: int = 0
var item_colocado_corretamente: bool = false
var eh_apenas_previa: bool = false

@onready var icone_material = _obter_icone()
@onready var texto_quantidade = _obter_texto()
@export var item_data: LixoData = null

func _obter_icone() -> Node:
	var no = get_node_or_null("IconeMaterial")
	if not no: no = get_node_or_null("iconeMaterial")
	if not no: no = find_child("*Icone*", true, false)
	return no

func _obter_texto() -> Node:
	var no = get_node_or_null("textoQuantidade")
	if not no: no = get_node_or_null("TextoQuantidade")
	if not no: no = find_child("*Quantidade*", true, false)
	return no

func setup_slot(textura: Texture2D, qtd_necessaria: int, previa: bool = false) -> void:
	eh_apenas_previa = previa
	textura_obrigatoria = textura
	
	if not icone_material: icone_material = _obter_icone()
	if not texto_quantidade: texto_quantidade = _obter_texto()
	
	if eh_apenas_previa:
		quantidade_obrigatoria = 0
		quantidade_acumulada = qtd_necessaria
		item_colocado_corretamente = true
		if icone_material:
			icone_material.texture = textura
			icone_material.modulate = Color(1, 1, 1, 1)
		if texto_quantidade:
			texto_quantidade.text = str(qtd_necessaria)
	else:
		quantidade_obrigatoria = qtd_necessaria
		quantidade_acumulada = 0
		item_colocado_corretamente = false
		if icone_material:
			icone_material.texture = textura_obrigatoria
			icone_material.modulate = Color(1, 1, 1, 0.8)
		_atualizar_texto_quantidade()

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if eh_apenas_previa:
		return false
		
	if not (data is Dictionary):
		return false

	if textura_obrigatoria != null:
		if data.has("sprite"):
			return data["sprite"] == textura_obrigatoria
		return false

	if data.has("item") and data["item"] is LixoData:
		return true

	return false

func _drop_data(_position: Vector2, data: Variant) -> void:
	if eh_apenas_previa:
		return

	if not icone_material: icone_material = _obter_icone()
	if not texto_quantidade: texto_quantidade = _obter_texto()
	
	var quantidade_jogador = int(data["amount"])
	quantidade_acumulada += quantidade_jogador
	
	if data.has("item") and data["item"] is LixoData:
		item_data = data["item"]
	
	if icone_material:
		if textura_obrigatoria != null:
			icone_material.texture = textura_obrigatoria
		elif data.has("sprite"):
			icone_material.texture = data["sprite"]
			
		icone_material.modulate = Color(1, 1, 1, 1)
		
	_atualizar_texto_quantidade()
	
	var slot_origem = data["backup"]
	if slot_origem and is_instance_valid(slot_origem):
		var sprite_inventario = slot_origem.get_node_or_null("sprite")
		var texto_inventario = slot_origem.get_node_or_null("amount")
		if sprite_inventario: sprite_inventario.texture = null
		if texto_inventario: texto_inventario.text = ""
		if "item_data" in slot_origem: slot_origem.item_data = null
		
	_avisar_tela_principal()

func _atualizar_texto_quantidade():
	if texto_quantidade:
		if quantidade_obrigatoria > 0:
			texto_quantidade.text = str(quantidade_acumulada) + "/" + str(quantidade_obrigatoria)
		else:
			texto_quantidade.text = str(quantidade_acumulada)
			
	item_colocado_corretamente = (quantidade_obrigatoria > 0 and quantidade_acumulada >= quantidade_obrigatoria) or (quantidade_obrigatoria == 0 and quantidade_acumulada > 0)

func consumir_material_forja():
	quantidade_acumulada -= quantidade_obrigatoria
	_atualizar_texto_quantidade()
	if quantidade_acumulada <= 0:
		quantidade_acumulada = 0
		item_colocado_corretamente = false
		if icone_material:
			icone_material.modulate = Color(1, 1, 1, 0.8)

func _gui_input(event: InputEvent) -> void:
	if eh_apenas_previa:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if quantidade_acumulada > 0:
			_devolver_itens_ao_inventario()

func _devolver_itens_ao_inventario():
	var canvas_inventario = null
	var no_atual = get_parent()
	while no_atual != null:
		if "canvass" in no_atual:
			canvas_inventario = no_atual.canvass
			break
		no_atual = no_atual.get_parent()
		
	if not canvas_inventario:
		canvas_inventario = get_tree().get_first_node_in_group("InterfaceUsuario")
		
	var textura_devolver = textura_obrigatoria
	if not textura_devolver and item_data:
		textura_devolver = item_data.textura
		
	if canvas_inventario:
		var todos_os_nos = canvas_inventario.find_children("*", "Control", true, false)
		var item_devolvido = false
		
		for no in todos_os_nos:
			if not no.has_method("set_empty_slot"):
				continue
			var sprite = no.get_node_or_null("sprite")
			var amount = no.get_node_or_null("amount")
			if sprite and amount and sprite.texture == textura_devolver:
				var qtd_inv = int(amount.text)
				if qtd_inv <= 0: qtd_inv = 1
				amount.text = str(qtd_inv + quantidade_acumulada)
				no.item_data = item_data
				item_devolvido = true
				break
				
		if not item_devolvido:
			for no in todos_os_nos:
				if not no.has_method("set_empty_slot"):
					continue
				var sprite = no.get_node_or_null("sprite")
				var amount = no.get_node_or_null("amount")
				if sprite and amount and sprite.texture == null:
					sprite.texture = textura_devolver
					amount.text = str(quantidade_acumulada)
					no.item_data = item_data
					item_devolvido = true
					break
					
		if item_devolvido:
			quantidade_acumulada = 0
			item_colocado_corretamente = false
			item_data = null
			_atualizar_texto_quantidade()
			if icone_material:
				if textura_obrigatoria != null:
					icone_material.texture = textura_obrigatoria
					icone_material.modulate = Color(1, 1, 1, 0.8)
				else:
					icone_material.texture = null
			_avisar_tela_principal()

func _avisar_tela_principal():
	var no_atual = get_parent()
	while no_atual != null:
		if no_atual.has_method("verificar_todas_as_receitas"):
			no_atual.verificar_todas_as_receitas()
			break
		no_atual = no_atual.get_parent()
