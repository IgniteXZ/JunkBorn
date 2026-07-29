extends Control

var posicaocidade: Array[Vector2] = [
	Vector2(833, 666),
	Vector2(757, 501),
	Vector2(391, 612),
]


@onready var iconejogador: Sprite2D = $iconejogador	
	
	
	
func _ready() -> void:
	var pos_atual = Global.cidade_atual
	
	iconejogador.global_position = posicaocidade[pos_atual]
