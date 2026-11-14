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
		
		HudEstilo.aplicar(self)
	HudEstilo.estilizar_janela($PanelContainer)
	HudEstilo.embrulhar_com_titulo($PanelContainer/divisaoPrincipal, "PRENSA")
		
func _process(_delta: float) -> void:
	_monitorar_previa()

func _obter_receita_do_item(lixo: LixoData) -> RecipeData:
	if not lixo:
		return null
		
	var nome_lixo_limpo = lixo.nome.replace(" ", "").to_lower() if lixo.nome else ""
	var path_lixo_limpo = lixo.resource_path.get_file().get_basename().replace(" ", "").to_lower() if lixo.resource_path else ""

	for receita in receitas:
		if not receita:
			continue

		if "item_resultado" in receita and receita.item_resultado == lixo:
			return receita

		if "nome_resultado" in receita and receita.nome_resultado != "":
			var nome_receita_limpo = receita.nome_resultado.replace(" ", "").to_lower()
			if nome_receita_limpo == nome_lixo_limpo or nome_receita_limpo == path_lixo_limpo:
				return receita
				
	
		if receita.resource_path != "":
			var nome_arquivo_receita = receita.resource_path.get_file().get_basename().replace(" ", "").to_lower()
			if nome_arquivo_receita == nome_lixo_limpo or nome_arquivo_receita == path_lixo_limpo:
				return receita
				
		 
		if "item_resultado" in receita and receita.item_resultado and receita.item_resultado.resource_path == lixo.resource_path:
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
		button_prensar.disabled = true
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
		var nome: String = receita.nome_material(receita.ingredientes.keys().find(ingrediente))
		if nome == "" and ingrediente is Object and "nome" in ingrediente:
			nome = str(ingrediente.nome)
		slot_previa.tooltip_text = nome

func _on_button_pressed() -> void:
	if not item_atual and slot_entrada and slot_entrada.item_data:
		item_atual = slot_entrada.item_data
		
	if slot_entrada and slot_entrada.quantidade_acumulada > 0:
		executar_desmanche()

const MATERIAIS_PRENSA = [
	preload("res://Resource/Itens/plastico.tres"),
	preload("res://Resource/Itens/metal.tres"),
	preload("res://Resource/Itens/corda.tres")
]


func _identificar_material(chave: Variant) -> LixoData:
	if chave is LixoData:
		return chave
	if not (chave is Texture2D):
		return null
	var registrado = Global.dados_por_textura.get(chave, null)
	if registrado is LixoData and registrado.textura == chave:
		return registrado
	for candidato in MATERIAIS_PRENSA:
		if candidato.textura == chave:
			return candidato
	return null


func executar_desmanche() -> void:
	var receita = _obter_receita_do_item(item_atual)
	if receita == null or slot_entrada.quantidade_acumulada <= 0:
		push_warning("Prensa: item sem receita válida.")
		return

	var inventario = canvass
	if inventario == null or not inventario.has_method("add_item_inventory"):
		inventario = get_tree().get_first_node_in_group("inventario")
	if inventario == null or not inventario.has_method("add_item_inventory"):
		push_warning("Prensa: inventário não encontrado; item preservado.")
		return

	var grid = inventario.get_node_or_null("inventory/GridContainer")
	if grid == null:
		return

	# 1. Calcula TODOS os itens que serão devolvidos, sem consumir a entrada.
	var saidas: Array[Dictionary] = []
	for chave in receita.ingredientes.keys():
		var recurso: LixoData = _identificar_material(chave)
		var qtd: int = int(receita.ingredientes[chave]) * slot_entrada.quantidade_acumulada
		if recurso == null or recurso.textura == null or qtd < 1:
			push_warning("Prensa: material da receita não identificado; desmanche cancelado.")
			return
		saidas.append({"recurso": recurso, "quantidade": qtd})

	# 2. Verifica espaço para todas as texturas diferentes, antes de alterar qualquer slot.
	var disponiveis: int = 0
	var texturas_ocupadas: Dictionary = {}
	for slot in grid.get_children():
		var textura = slot.get_node("sprite").texture
		if textura == null:
			disponiveis += 1
		else:
			texturas_ocupadas[textura] = true
	for saida in saidas:
		var textura = saida["recurso"].textura
		if not texturas_ocupadas.has(textura):
			disponiveis -= 1
			texturas_ocupadas[textura] = true
	if disponiveis < 0:
		print("Prensa: espaço insuficiente; item continua na prensa.")
		return

	# 3. Snapshot para desfazer qualquer inserção parcial inesperada.
	var anterior: Array[Dictionary] = []
	for slot in grid.get_children():
		anterior.append({
			"textura": slot.get_node("sprite").texture,
			"quantidade": slot.get_node("amount").text,
			"recurso": slot.item_data,
			"id": int(slot.get_meta("item_id", -1)),
			"protegido": bool(slot.get_meta("protegido_drone", false))
		})

	# 4. Entrega todos os materiais pelos IDs corretos.
	for saida in saidas:
		var recurso: LixoData = saida["recurso"]
		for i in range(saida["quantidade"]):
			if not inventario.add_item_inventory(recurso.item_id, recurso.textura, recurso.nome, recurso):
				for j in range(anterior.size()):
					var slot = grid.get_child(j)
					var estado = anterior[j]
					slot.get_node("sprite").texture = estado["textura"]
					slot.get_node("amount").text = estado["quantidade"]
					slot.item_data = estado["recurso"]
					if estado["id"] >= 0:
						slot.set_meta("item_id", estado["id"])
					elif slot.has_meta("item_id"):
						slot.remove_meta("item_id")
					slot.set_meta("protegido_drone", estado["protegido"])
				inventario.salvar_inventario()
				push_warning("Prensa: falha no inventário, desmanche cancelado.")
				return

	# 5. Apenas AGORA consome o item, depois do sucesso total.
	slot_entrada.quantidade_acumulada = 0
	slot_entrada.item_data = null
	slot_entrada.item_colocado_corretamente = false
	if slot_entrada.icone_material:
		slot_entrada.icone_material.texture = null
	slot_entrada._atualizar_texto_quantidade()
	item_atual = null
	button_prensar.disabled = true
	button_prensar.modulate = Color.WHITE
	_gerar_icones_previa()


# Só fecha após devolver a entrada. Falha no retorno mantém a interface aberta.
func fechar_tela() -> bool:
	if slot_entrada and slot_entrada.quantidade_acumulada > 0:
		if not slot_entrada._devolver_itens_ao_inventario():
			return false
	queue_free()
	return true


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
