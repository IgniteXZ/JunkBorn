extends PanelContainer
class_name SlotMaterial

var textura_obrigatoria: Texture2D = null
var quantidade_obrigatoria: int = 0
var quantidade_acumulada: int = 0
var item_colocado_corretamente: bool = false

@onready var icone_material = get_node_or_null("IconeMaterial") if get_node_or_null("IconeMaterial") else get_node_or_null("iconeMaterial")
@onready var texto_quantidade = get_node_or_null("textoQuantidade") if get_node_or_null("textoQuantidade") else get_node_or_null("TextoQuantidade")

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("sprite") and data.has("amount"):
		if data["sprite"] == textura_obrigatoria:
			return true
	return false

func _drop_data(_position: Vector2, data: Variant) -> void:
	if not icone_material: icone_material = find_child("*Icone*", true, false)
	if not texto_quantidade: texto_quantidade = find_child("*Quantidade*", true, false)
	
	var quantidade_jogador = int(data["amount"])
	quantidade_acumulada += quantidade_jogador
	
	if icone_material:
		icone_material.texture = textura_obrigatoria
		icone_material.modulate = Color(1, 1, 1, 1) # Acende 100% colorido ao dropar
		
	_atualizar_texto_quantidade()
	
	var slot_origem = data["backup"]
	if slot_origem and is_instance_valid(slot_origem):
		var sprite_inventario = slot_origem.get_node_or_null("sprite")
		var texto_inventario = slot_origem.get_node_or_null("amount")
		if sprite_inventario: sprite_inventario.texture = null
		if texto_inventario: texto_inventario.text = ""
		
	_avisar_tela_principal()

func _atualizar_texto_quantidade():
	if texto_quantidade:
		texto_quantidade.text = str(quantidade_acumulada) + "/" + str(quantidade_obrigatoria)
	item_colocado_corretamente = (quantidade_acumulada >= quantidade_obrigatoria)

func consumir_material_forja():
	quantidade_acumulada -= quantidade_obrigatoria
	_atualizar_texto_quantidade()
	if quantidade_acumulada <= 0:
		quantidade_acumulada = 0
		item_colocado_corretamente = false
		if icone_material:
			icone_material.modulate = Color(1, 1, 1, 0.8) # Volta para o fantasma nítido

func _gui_input(event: InputEvent) -> void:
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
		
	if canvas_inventario:
		var todos_os_nos = canvas_inventario.find_children("*", "Control", true, false)
		var item_devolvido = false
		
		for no in todos_os_nos:
			var sprite = no.get_node_or_null("sprite")
			var amount = no.get_node_or_null("amount")
			if sprite and amount and sprite.texture == textura_obrigatoria:
				var qtd_inv = int(amount.text)
				if qtd_inv <= 0: qtd_inv = 1
				amount.text = str(qtd_inv + quantidade_acumulada)
				item_devolvido = true
				break
				
		if not item_devolvido:
			for no in todos_os_nos:
				var sprite = no.get_node_or_null("sprite")
				var amount = no.get_node_or_null("amount")
				if sprite and amount and sprite.texture == null:
					sprite.texture = textura_obrigatoria
					amount.text = str(quantidade_acumulada)
					item_devolvido = true
					break
					
		if item_devolvido:
			quantidade_acumulada = 0
			item_colocado_corretamente = false
			if texto_quantidade:
				texto_quantidade.text = "0/" + str(quantidade_obrigatoria)
			if icone_material:
				icone_material.modulate = Color(1, 1, 1, 0.8) # Reseta para o fantasma nítido
			_avisar_tela_principal()
		else:
			print("ERRO: Não há espaço no inventário para devolver os itens!")

func _avisar_tela_principal():
	var no_atual = get_parent()
	while no_atual != null:
		if no_atual.has_method("verificar_todas_as_receitas"):
			no_atual.verificar_todas_as_receitas()
			break
		no_atual = no_atual.get_parent()
