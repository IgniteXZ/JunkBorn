extends Control

@export_range(0, 100, 1) var paginas_iniciais: int = 2
@export var pagina_rasgada_esquerda: Texture2D = preload("res://HUD/sprites/pgVazia1.png")
@export var pagina_rasgada_direita: Texture2D = preload("res://HUD/sprites/pgVazia2.png")

# Cada entrada e UMA pagina, na ordem esquerda, direita, esquerda, direita.
# Preencha o texto entre aspas, mantendo a imagem de cada pagina.
@export var paginas: Array[Dictionary] = [
	{"text": "Planta suculenta extremamente resistente, com folhas verticais rígidas e rajadas que sobrevivem mesmo em condições hostis. No ambiente, destaca-se pela capacidade única de converter gás carbônico em oxigênio durante a noite, além de filtrar toxinas como benzeno. Para a saúde, purifica continuamente o ar de ambientes fechados, favorecendo o sono e reduzindo alergias respiratórias. No jogo, gera 'bolhas de ar puro' que protegem Filomeno contra a fumaça tóxica da Rauch Company.", "illustration": preload("res://HUD/sprites/diarioPagina1.png")},
	{"text": "omagaaa", "illustration": preload("res://HUD/sprites/diarioPagina2.png")},
	{"text": "", "illustration": preload("res://HUD/sprites/diarioPagina3.png")},
	{"text": "", "illustration": preload("res://HUD/sprites/diarioPagina4.png")}
]

@onready var foto_esquerda: TextureRect = $BookArea/Esquerda/Fundo
@onready var texto_esquerda: RichTextLabel = $BookArea/Esquerda/Texto
@onready var foto_direita: TextureRect = $BookArea/Direita/Fundo
@onready var texto_direita: RichTextLabel = $BookArea/Direita/Texto
@onready var botao_voltar: Button = $BookArea/Voltar
@onready var botao_avancar: Button = $BookArea/Avancar
@onready var botao_fechar: Button = $BookArea/Fechar

var indice_esquerda: int = 0


func _ready() -> void:
	botao_voltar.pressed.connect(_voltar)
	botao_avancar.pressed.connect(_avancar)
	botao_fechar.pressed.connect(hide)
	visibility_changed.connect(_atualizar_se_aberto)
	atualizar_paginas()


func _atualizar_se_aberto() -> void:
	if visible:
		atualizar_paginas()


func atualizar_paginas() -> void:
	if paginas.is_empty():
		foto_esquerda.hide()
		texto_esquerda.hide()
		foto_direita.hide()
		texto_direita.hide()
		botao_voltar.disabled = true
		botao_avancar.disabled = true
		return

	var coletou_semente: bool = Global.itens_coletados.has("fonte_semente_1")

	_mostrar_pagina(indice_esquerda, foto_esquerda, texto_esquerda, pagina_rasgada_esquerda, coletou_semente)

	var indice_direita: int = indice_esquerda + 1
	if indice_direita < paginas.size():
		_mostrar_pagina(indice_direita, foto_direita, texto_direita, pagina_rasgada_direita, coletou_semente)
	else:
		foto_direita.hide()
		texto_direita.hide()

	botao_voltar.disabled = indice_esquerda == 0
	botao_avancar.disabled = indice_esquerda + 2 >= paginas.size()


func _mostrar_pagina(indice: int, foto: TextureRect, texto: RichTextLabel, rasgada: Texture2D, coletou_semente: bool) -> void:
	var liberada: bool = indice < paginas_iniciais or coletou_semente
	var dados: Dictionary = paginas[indice]

	foto.texture = dados.get("illustration", null) if liberada else rasgada
	foto.show()

	texto.text = str(dados.get("text", "")) if liberada else ""
	texto.visible = liberada


func _voltar() -> void:
	if indice_esquerda >= 2:
		indice_esquerda -= 2
		atualizar_paginas()


func _avancar() -> void:
	if indice_esquerda + 2 < paginas.size():
		indice_esquerda += 2
		atualizar_paginas()
