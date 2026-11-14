extends Control
const LINHA_FORJA_SCENE = preload("res://Minigames/Forja/linhaForja.tscn")
@export var receitas: Array[RecipeData] = []
@onready var lista_de_itens = $divisaoPrincipal/areaDaLista/listaDeItens
@onready var botao_forjar_universal = $divisaoPrincipal/Button
var linhas_carregadas: Array[LinhaForja] = []
var canvass = null
func _ready():
	botao_forjar_universal.disabled = true
	botao_forjar_universal.modulate = Color(1, 1, 1)
	for receita in receitas:
		var nova_linha = LINHA_FORJA_SCENE.instantiate()
		lista_de_itens.add_child(nova_linha)
		nova_linha.configurar_linha(receita)
		linhas_carregadas.append(nova_linha)
		
	HudEstilo.aplicar(self)
	HudEstilo.embrulhar_com_titulo($divisaoPrincipal, "FORJA", true)

func verificar_todas_as_receitas():
	var alguma_receita_pronta = false
	for linha in linhas_carregadas:
		linha.atualizar_destaque()
		if linha.verificar_linha_completa():
			alguma_receita_pronta = true
	botao_forjar_universal.disabled = not alguma_receita_pronta
	botao_forjar_universal.modulate = Color(0.7, 1, 0.7) if alguma_receita_pronta else Color(1, 1, 1)

func _obter_recurso_da_receita(receita: RecipeData) -> LixoData:
	for prop in receita.get_property_list():
		var valor = receita.get(prop.name)
		if valor is LixoData:
			return valor
	print(">>> ATENÇÃO: A receita '", receita.nome_resultado if "nome_resultado" in receita else "Sem Nome", "' não tem nenhum LixoData associado no Inspetor!")
	return null
func _on_button_pressed() -> void:
	var inventario = get_tree().get_first_node_in_group("inventario")

	if inventario == null:
		push_error("Forja: inventário não encontrado!")
		return

	for i in range(linhas_carregadas.size()):
		var linha = linhas_carregadas[i]
		var receita = receitas[i]

		if not linha.verificar_linha_completa():
			continue

		var resultado: LixoData = receita.item_resultado

		if resultado == null or resultado.textura == null:
			push_warning("Forja: resultado inválido em " + receita.nome_resultado)
			continue

		var adicionado = inventario.add_item_inventory(
			resultado.item_id,
			resultado.textura,
			resultado.nome,
			resultado
		)

		if not adicionado:
			print("Forja: inventário cheio!")
			continue

		# Só consome os ingredientes após adicionar o item
		for slot in linha.slots_da_linha:
			slot.consumir_material_forja()

	verificar_todas_as_receitas()
	
func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
