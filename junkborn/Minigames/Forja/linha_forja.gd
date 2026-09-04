extends HBoxContainer
class_name LinhaForja

const SLOT_MATERIAL_SCENE = preload("res://Minigames/Forja/slotMaterial.tscn")

@onready var icone_resultado = $iconeResultado
@onready var container_materiais = $containerMateriais

var slots_da_linha: Array[SlotMaterial] = []

func configurar_linha(receita: RecipeData):
	icone_resultado.texture = receita.icone_resultado
	
	for filho in container_materiais.get_children():
		filho.queue_free()
		
	slots_da_linha.clear()
	
	var lista_ingredientes = receita.ingredientes.keys()
	
	for i in range(lista_ingredientes.size()):
		var imagem_item = lista_ingredientes[i]
		var quantidade_necessaria = receita.ingredientes[imagem_item]
		
		var novo_slot = SLOT_MATERIAL_SCENE.instantiate()
		
		novo_slot.textura_obrigatoria = imagem_item
		novo_slot.quantidade_obrigatoria = quantidade_necessaria
		
		container_materiais.add_child(novo_slot)
		slots_da_linha.append(novo_slot)
		
		var icone_slot = novo_slot.get_node_or_null("IconeMaterial")
		var texto_slot = novo_slot.get_node_or_null("textoQuantidade")
		
		if icone_slot:
			icone_slot.texture = imagem_item
			icone_slot.modulate = Color(1, 1, 1, 0.8)
		if texto_slot:
			texto_slot.text = "0/" + str(quantidade_necessaria)
		
		if i < lista_ingredientes.size() - 1:
			var sinal_mais = Label.new()
			sinal_mais.text = "+"
			container_materiais.add_child(sinal_mais)

func verificar_linha_completa() -> bool:
	for slot in slots_da_linha:
		if not slot.item_colocado_corretamente:
			return false
	return true
