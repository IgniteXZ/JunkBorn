extends Control

@export var fotodireita: TextureRect
@export var textodireita: RichTextLabel
@export var fotoesquerda: TextureRect
@export var textoesquerda: RichTextLabel
@export var botaovoltapag: Button
@export var botaoavancapag: Button

@export var bloquear_paginas: bool = false
@export var rasgada_esquerda: Texture2D
@export var rasgada_direita: Texture2D
@export var texto_bloqueado: String = ""

@export var pages: Array[Dictionary] = [
	{"text": "Página 1: Introdução da nossa grande jornada...", "illustration": preload("res://HUD/sprites/semente1.png")},
	{"text": "Página 2: O herói encontra um mapa antigo.", "illustration": preload("res://HUD/sprites/semente2.png")},
	{"text": "Página 3: A floresta escura parecia não ter fim.", "illustration": preload("res://HUD/sprites/semente3.png")},
	{"text": "Página 4: Um castelo de cristal surge entre as nuvens.", "illustration": preload("res://HUD/sprites/semente4.png")},
	{"text": "Página 5: Fim do primeiro capítulo!", "illustration": preload("res://HUD/sprites/semente5.png")}
]

var current_left_index: int = 0

func _ready() -> void:
	update_book_pages()
	botaovoltapag.pressed.connect(_on_prev_pressed)
	botaoavancapag.pressed.connect(_on_next_pressed)
	visibility_changed.connect(update_book_pages)

func update_book_pages() -> void:
	_mostrar_pagina(fotoesquerda, textoesquerda, pages[current_left_index], rasgada_esquerda)

	var right_index = current_left_index + 1
	if right_index < pages.size():
		_mostrar_pagina(fotodireita, textodireita, pages[right_index], rasgada_direita)
		fotodireita.show()
		textodireita.show()
	else:
		fotodireita.hide()
		textodireita.hide()

	botaovoltapag.disabled = (current_left_index == 0)
	botaoavancapag.disabled = (right_index >= pages.size() - 1)

func _mostrar_pagina(foto: TextureRect, texto: RichTextLabel, data: Dictionary, rasgada: Texture2D) -> void:
	var liberada = not bloquear_paginas or Global.paginas_coletadas.has(data.get("id", ""))
	texto.text = data.get("text", "") if liberada else texto_bloqueado
	foto.texture = data.get("illustration") if liberada else rasgada

func _on_prev_pressed() -> void:
	if current_left_index >= 2:
		current_left_index -= 2
		update_book_pages()

func _on_next_pressed() -> void:
	if current_left_index + 2 < pages.size():
		current_left_index += 2
		update_book_pages()
