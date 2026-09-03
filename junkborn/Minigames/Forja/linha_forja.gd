extends HBoxContainer
class_name LinhaForja

const SLOT_MATERIAL_SCENE = preload("res://Minigames/Forja/slotMaterial.tscn")

@onready var icone_resultado = $IconeResultado
@onready var container_materiais = $containerMateriais

var slots_da_linha: Array[SlotMaterial] = []

func configurar_linha(receita: RecipeData):
	icone_resultado.texture = receita.icone_resultado
	
	for filho in container_materiais.get_children():
		filho.queue_free()
		
	slots_da_linha.clear()
	
	var lista_ingredientes = receita.ingredientes.keys()
	
	for i in range(lista_ingredientes.size()):
		var item = lista_ingredientes[i]
		var quantidade_necessaria = receita.ingredientes[item]
		
		var novo_slot = SLOT_MATERIAL_SCENE.instantiate()
		container_materiais.add_child(novo_slot)
		

		slots_da_linha.append(novo_slot)
		

		novo_slot.textura_obrigatoria = item.icone
		novo_slot.quantidade_obrigatoria = quantidade_necessaria
		

		novo_slot.get_node("IconeMaterial").texture = item.icone
		novo_slot.get_node("IconeMaterial").modulate = Color(0.2, 0.2, 0.2, 0.6)
		novo_slot.get_node("textoQuantidade").text = "x" + str(quantidade_necessaria)
		
		if i < lista_ingredientes.size() - 1:
			var sinal_mais = Label.new()
			sinal_mais.text = "+"
			container_materiais.add_child(sinal_mais)


func verificar_linha_completa() -> bool:
	for slot in slots_da_linha:
		if not slot.item_colocado_corretamente:
			return false
	return true
