extends Node2D

signal fechar_coleta

@export var lixo_scene: PackedScene
@export var lista_de_lixos: Array[LixoData] = []
@export var quantidade_lixos: int = 25

@export var limite_minimo: Vector2 = Vector2(30, 100)
@export var limite_maximo: Vector2 = Vector2(1050, 700)

@export var espacamento_lixos: float = 85.0

@onready var monte_coleta: Sprite2D = $MonteColeta
@onready var imagem_monte: Image = $MonteColeta.texture.get_image()
@onready var caixa_dialogo: Control = $DialogoColeta/CaixaDialogo
@onready var texto_dialogo: RichTextLabel = $DialogoColeta/CaixaDialogo/MargemDialogo/HBoxDialogo/TextoDialogo
@onready var dialogo_coleta: CanvasLayer = $DialogoColeta

var posicoes_ocupadas: Array[Vector2] = []


func _ready() -> void:
	randomize()
	dialogo_coleta.hide()

	for i in range(quantidade_lixos):
		spawnar_lixo()


func randomizar_lixos() -> void:
	for child in get_children():
		if child.has_method("configurar"):
			child.queue_free()

	await get_tree().create_timer(0.05).timeout
	posicoes_ocupadas.clear()

	for i in range(quantidade_lixos):
		spawnar_lixo()


func _posicao_valida_no_monte(posicao: Vector2) -> bool:
	var posicao_global: Vector2 = to_global(posicao)
	var posicao_na_imagem: Vector2 = monte_coleta.to_local(posicao_global)
	posicao_na_imagem += monte_coleta.texture.get_size() * 0.5

	var pixel := Vector2i(posicao_na_imagem)
	if pixel.x < 0 or pixel.y < 0:
		return false
	if pixel.x >= imagem_monte.get_width() or pixel.y >= imagem_monte.get_height():
		return false

	return imagem_monte.get_pixelv(pixel).a > 0.2


func _posicao_livre(posicao: Vector2) -> bool:
	for outra_posicao in posicoes_ocupadas:
		if absf(posicao.x - outra_posicao.x) < espacamento_lixos \
		and absf(posicao.y - outra_posicao.y) < espacamento_lixos:
			return false

	return true


func spawnar_lixo() -> void:
	if lista_de_lixos.is_empty() or not lixo_scene:
		push_warning("Configure lixo_scene e lista_de_lixos no Inspector!")
		return

	var posicao := Vector2.ZERO
	var encontrou_posicao := false

	for tentativa in range(500):
		posicao = Vector2(
			randf_range(limite_minimo.x, limite_maximo.x),
			randf_range(limite_minimo.y, limite_maximo.y)
		)

		if _posicao_valida_no_monte(posicao) and _posicao_livre(posicao):
			encontrou_posicao = true
			break

	if not encontrou_posicao:
		push_warning("Não foi possível posicionar mais lixos sem sobreposição.")
		return

	var novo_lixo_node = lixo_scene.instantiate()
	var lixo_aleatorio: LixoData = lista_de_lixos.pick_random()

	add_child(novo_lixo_node)
	novo_lixo_node.position = posicao
	novo_lixo_node.configurar(lixo_aleatorio, caixa_dialogo, texto_dialogo)
	posicoes_ocupadas.append(posicao)


func _on_button_pressed() -> void:
	randomizar_lixos()
