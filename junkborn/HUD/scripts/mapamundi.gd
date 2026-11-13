
extends Control

@export var iconejogador: Sprite2D
@onready var imagem_mapa: TextureRect = $TextureRect


var posicaocidade: Array[Vector2] = [
	Vector2(0.777, 0.255), #vila 0
	Vector2(0.60, 0.21), #deserto1 1
	Vector2(0.70, 0.677),  #deserto2 2
	Vector2(0.81, 0.196),  #forja 3
	Vector2(0.433, 0.226),  #desertoFonte 4
	Vector2(0.256, 0.299),  #pantano quimico 5
	Vector2(0.404, 0.33),  #fonte 6
	Vector2(0.4515, 0.6319),  #mina 7




]

func _process(_delta: float) -> void:
	var pos_atual = Global.cidade_atual

	if pos_atual < 0 or pos_atual >= posicaocidade.size():
		return

	if iconejogador == null or imagem_mapa.texture == null:
		return

	var tamanho_textura = imagem_mapa.texture.get_size()
	var escala = minf(
		imagem_mapa.size.x / tamanho_textura.x,
		imagem_mapa.size.y / tamanho_textura.y
	)

	var tamanho_imagem = tamanho_textura * escala
	var margem = (imagem_mapa.size - tamanho_imagem) / 2.0

	iconejogador.position = margem + tamanho_imagem * posicaocidade[pos_atual]
