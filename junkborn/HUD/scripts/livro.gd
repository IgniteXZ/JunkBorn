extends Control

@export var fotodireita: TextureRect
@export var textodireita: RichTextLabel

@export var fotoesquerda: TextureRect
@export var textoesquerda: RichTextLabel


@export var botaovoltapag: Button
@export var botaoavancapag: Button

var pages: Array[Dictionary] = [
	{"text": "Página 1: Introdução da nossa grande jornada...", "illustration": preload("res://HUD/sprites/semente1.png")},
	{"text": "Página 2: O herói encontra um mapa antigo.", "illustration": preload("res://HUD/sprites/semente2.png")},
	{"text": "Página 3: A floresta escura parecia não ter fim.", "illustration": preload("res://HUD/sprites/semente3.png")},
	{"text": "Página 4: Um castelo de cristal surge entre as nuvens.", "illustration": preload("res://HUD/sprites/semente4.png")},
	{"text": "Página 5: Fim do primeiro capítulo!", "illustration": preload("res://HUD/sprites/semente5.png")}
]

var current_left_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Atualiza o livro pela primeira vez ao abrir a tela
	update_book_pages()
	
	# Conecta os cliques dos seus botões exportados às funções abaixo
	botaovoltapag.pressed.connect(_on_prev_pressed)
	botaoavancapag.pressed.connect(_on_next_pressed)

func update_book_pages() -> void:
	# 1. ATUALIZA A PÁGINA ESQUERDA
	var left_data = pages[current_left_index]
	textoesquerda.text = left_data["text"]
	fotoesquerda.texture = left_data["illustration"]
	
	# 2. ATUALIZA A PÁGINA DIREITA (Calcula o próximo índice)
	var right_index = current_left_index + 1
	
	if right_index < pages.size():
		# Se a página da direita existir, mostra o conteúdo dela
		var right_data = pages[right_index]
		textodireita.text = right_data["text"]
		fotodireita.texture = right_data["illustration"]
		fotodireita.show()
		textodireita.show()
	else:
		# Se o livro tiver páginas ímpares, esconde o lado direito no final
		fotodireita.hide()
		textodireita.hide()
		
	# 3. CONTROLE DOS BOTÕES (Ativa ou desativa baseado na página)
	# Desativa o botão "Voltar" se estiver na primeira página (índice 0)
	botaovoltapag.disabled = (current_left_index == 0)
	
	# Desativa o botão "Avançar" se não houver mais páginas para criar uma nova dupla
	botaoavancapag.disabled = (right_index >= pages.size() - 1)

func _on_prev_pressed() -> void:
	if current_left_index >= 2:
		current_left_index -= 2 # Volta duas páginas de uma vez
		update_book_pages()

func _on_next_pressed() -> void:
	if current_left_index + 2 < pages.size():
		current_left_index += 2 # Avança duas páginas de uma vez
		update_book_pages()
