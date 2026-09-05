extends Control
class_name TelaPrensa

@export var receitas: Array[RecipeData] = []

@onready var slot_entrada: SlotMaterial = $PanelContainer/divisaoPrincipal/SlotMaterial
@onready var container_previa: HBoxContainer = $PanelContainer/divisaoPrincipal/previa
@onready var button_prensar: Button = $PanelContainer/divisaoPrincipal/prensar

const SLOT_PREVIA_SCENE = preload("res://Minigames/Forja/slotMaterial.tscn")

var canvass = null
var item_atual: LixoData = null

func _ready() -> void:
	if not button_prensar.pressed.is_connected(_on_button_pressed):
		button_prensar.pressed.connect(_on_button_pressed)
	if not canvass:
		canvass = get_tree().get_first_node_in_group("InterfaceUsuario")

func _process(_delta: float) -> void:
	_monitorar_previa()

func _obter_receita_do_item(lixo: LixoData) -> RecipeData:
	if not lixo:
		return null
	for receita in receitas:
		var recurso_receita = null
		if "item_resultado" in receita and receita.item_resultado:
			recurso_receita = receita.item_resultado
		else:
			for prop in receita.get_property_list():
				var val = receita.get(prop.name)
				if val is LixoData:
					recurso_receita = val
					break
		
		if recurso_receita == lixo:
			return receita
	return null

func _monitorar_previa() -> void:
	var item_no_slot = slot_entrada.item_data if ("quantidade_acumulada" in slot_entrada and slot_entrada.quantidade_acumulada > 0) else null
	
	if item_no_slot != item_atual:
		item_atual = item_no_slot
		_gerar_icones_previa()

func _gerar_icones_previa() -> void:
	for filho in container_previa.get_children():
		filho.queue_free()
		
	var receita = _obter_receita_do_item(item_atual)
	
	if receita and slot_entrada.quantidade_acumulada > 0:
		button_prensar.modulate = Color(1.0, 0.2, 0.2, 1.0)
		button_prensar.disabled = false
	else:
		button_prensar.modulate = Color(1.0, 1.0, 1.0, 1.0)
		button_prensar.disabled = false
		return
		
	var qtd_itens = slot_entrada.quantidade_acumulada if "quantidade_acumulada" in slot_entrada else 1
	
	for ingrediente in receita.ingredientes.keys():
		var qtd_final = receita.ingredientes[ingrediente] * qtd_itens
		
		var slot_previa = SLOT_PREVIA_SCENE.instantiate()
		container_previa.add_child(slot_previa)
		
		var tex: Texture2D = null
		if ingrediente is LixoData and ingrediente.textura:
			tex = ingrediente.textura
		elif "textura" in ingrediente:
			tex = ingrediente.textura
		elif ingrediente is Texture2D:
			tex = ingrediente
			
		if slot_previa.has_method("setup_slot"):
			slot_previa.setup_slot(tex, qtd_final, true)

func _on_button_pressed() -> void:
	if not item_atual and slot_entrada and slot_entrada.item_data:
		item_atual = slot_entrada.item_data
		
	if slot_entrada and slot_entrada.quantidade_acumulada > 0:
		executar_desmanche()

func executar_desmanche() -> void:
	var receita = _obter_receita_do_item(item_atual)
	if not receita:
		print(">>> ERRO: Receita não encontrada para o item: ", item_atual)
		return
		
	var qtd_itens = slot_entrada.quantidade_acumulada

	slot_entrada.quantidade_acumulada = 0
	if "item_data" in slot_entrada:
		slot_entrada.item_data = null
	if slot_entrada.icone_material:
		slot_entrada.icone_material.texture = null
	if slot_entrada.texto_quantidade:
		slot_entrada.texto_quantidade.text = ""
	
	item_atual = null
	button_prensar.modulate = Color(1.0, 1.0, 1.0, 1.0)

	var canvas_inv = canvass
	if not canvas_inv:
		canvas_inv = get_tree().get_first_node_in_group("InterfaceUsuario")

	if not canvas_inv:
		print(">>> ERRO: Interface de usuário não encontrada!")
		_gerar_icones_previa()
		return

	var todos_os_nos = canvas_inv.find_children("*", "Control", true, false)

	for ingrediente in receita.ingredientes.keys():
		var qtd_final = receita.ingredientes[ingrediente] * qtd_itens
		
		var tex: Texture2D = null
		var recurso_ingrediente = ingrediente
		
		if ingrediente is Texture2D:
			tex = ingrediente
			recurso_ingrediente = null
		elif ingrediente is Object and "textura" in ingrediente:
			tex = ingrediente.textura
			
		if not tex:
			continue

		var item_adicionado = false

		for no in todos_os_nos:
			if not no.has_method("set_empty_slot") or no == slot_entrada:
				continue
				
			var sprite = no.get_node_or_null("sprite")
			var amount = no.get_node_or_null("amount")
			
			if sprite and amount and sprite.texture == tex:
				var qtd_atual = int(amount.text)
				if qtd_atual <= 0: 
					qtd_atual = 1
				
				amount.text = str(qtd_atual + qtd_final)
				
				if recurso_ingrediente and "item_data" in no:
					no.item_data = recurso_ingrediente
					
				item_adicionado = true
				break

		if not item_adicionado:
			for no in todos_os_nos:
				if not no.has_method("set_empty_slot") or no == slot_entrada:
					continue
					
				var sprite = no.get_node_or_null("sprite")
				var amount = no.get_node_or_null("amount")
				
				if sprite and amount and sprite.texture == null:
					sprite.texture = tex
					amount.text = str(qtd_final)
					
					if recurso_ingrediente and "item_data" in no:
						no.item_data = recurso_ingrediente
						
					item_adicionado = true
					break

		if not item_adicionado:
			print(">>> AVISO: Inventário cheio! Não foi possível adicionar: ", tex)

	_gerar_icones_previa()

func _adicionar_material_ao_inventario(_ingrediente: Variant, _quantidade: int) -> void:
	pass
				
func fechar_tela() -> void:
	if slot_entrada and slot_entrada.quantidade_acumulada > 0:
		if slot_entrada.has_method("_devolver_itens_ao_inventario"):
			slot_entrada._devolver_itens_ao_inventario()
	queue_free()

func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
