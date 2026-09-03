extends Control

const LINHA_FORJA_SCENE = preload("res://Minigames/Forja/linhaForja.tscn")

@export var receitas: Array[RecipeData] = []
@onready var lista_de_itens = $divisaoPrincipal/areaDaLista/listaDeItens
@onready var botao_forjar_universal = $divisaoPrincipal/Button

var linhas_carregadas: Array[LinhaForja] = []

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
	for i in range(linhas_carregadas.size()):
		var linha = linhas_carregadas[i]
		var receita = receitas[i]
		
		if linha.verificar_linha_completa():
			print("FORJADO COM SUCESSO: ", receita.nome_resultado)


	verificar_todas_as_receitas()
