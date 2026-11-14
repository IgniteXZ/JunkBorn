extends HBoxContainer
class_name LinhaForja

const SLOT_MATERIAL_SCENE = preload("res://Minigames/Forja/slotMaterial.tscn")

@onready var icone_resultado = $iconeResultado
@onready var container_materiais = $containerMateriais

var slots_da_linha: Array[SlotMaterial] = []

func atualizar_destaque() -> void:
	var pronta := verificar_linha_completa()
	icone_resultado.modulate = Color(1, 1, 1, 1) if pronta else Color(1, 1, 1, 0.5)

func configurar_linha(receita: RecipeData):
	
	icone_resultado.texture = receita.icone_resultado
	icone_resultado.mouse_filter = Control.MOUSE_FILTER_STOP
	icone_resultado.tooltip_text = HudEstilo.quebrar_linhas(receita.texto_resultado())
	
	
	for filho in container_materiais.get_children():
		filho.queue_free()
		
	slots_da_linha.clear()
	
	var lista_ingredientes = receita.ingredientes.keys()
	
	for i in range(lista_ingredientes.size()):
		var imagem_item = lista_ingredientes[i]
		var quantidade_necessaria = receita.ingredientes[imagem_item]
		
		var novo_slot = SLOT_MATERIAL_SCENE.instantiate()
		
		container_materiais.add_child(novo_slot)
		slots_da_linha.append(novo_slot)
		
		novo_slot.setup_slot(imagem_item, quantidade_necessaria)
		
		var nome: String = receita.nome_material(i)
		if nome == "" and Global.nomes_itens.has(imagem_item):
			nome = str(Global.nomes_itens[imagem_item])
		novo_slot.tooltip_text = nome
		
		if i < lista_ingredientes.size() - 1:
			var sinal_mais = Label.new()
			sinal_mais.text = "+"
			container_materiais.add_child(sinal_mais)
		atualizar_destaque()

func verificar_linha_completa() -> bool:
	for slot in slots_da_linha:
		if not slot.item_colocado_corretamente:
			return false
	return true
