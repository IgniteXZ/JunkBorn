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

func verificar_todas_as_receitas():
	var alguma_receita_pronta = false
	for linha in linhas_carregadas:
		if linha.verificar_linha_completa():
			alguma_receita_pronta = true
			break
	if alguma_receita_pronta:
		botao_forjar_universal.disabled = false
		botao_forjar_universal.modulate = Color(0, 1, 0)
	else:
		botao_forjar_universal.disabled = true
		botao_forjar_universal.modulate = Color(1, 1, 1)

func _on_button_pressed():
	var canvas_inventario = canvass
	if not canvas_inventario:
		canvas_inventario = get_tree().get_first_node_in_group("InterfaceUsuario")
	if not canvas_inventario:
		canvas_inventario = get_parent() as CanvasLayer
	for i in range(linhas_carregadas.size()):
		var linha = linhas_carregadas[i]
		var receita = receitas[i]
		if linha.verificar_linha_completa():
			print("FORJADO COM SUCESSO: ", receita.nome_resultado)
			var item_adicionado = false
			if canvas_inventario:
				var todos_os_nos = canvas_inventario.find_children("*", "Control", true, false)
				for no in todos_os_nos:
					var sprite = no.get_node_or_null("sprite")
					var amount = no.get_node_or_null("amount")
					if sprite and amount and sprite.texture == receita.icone_resultado:
						var qtd_atual = int(amount.text)
						if qtd_atual <= 0: qtd_atual = 1
						amount.text = str(qtd_atual + 1)
						item_adicionado = true
						break
				if not item_adicionado:
					for no in todos_os_nos:
						var sprite = no.get_node_or_null("sprite")
						var amount = no.get_node_or_null("amount")
						if sprite and amount and sprite.texture == null:
							sprite.texture = receita.icone_resultado
							amount.text = "1"
							item_adicionado = true
							break
			if item_adicionado:
				for slot in linha.slots_da_linha:
					if slot.has_method("consumir_material_forja"):
						slot.consumir_material_forja()
			else:
				print("ERRO: Inventário cheio! Forja cancelada.")
	verificar_todas_as_receitas()

func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
