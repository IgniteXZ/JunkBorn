extends Control

var posicaocidade: Array[Vector2] = [
	Vector2(810, 254),
	Vector2(602, 231),
	Vector2(391, 612),
]


@export var iconejogador: Sprite2D
	
	
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var pos_atual = Global.cidade_atual
	
	iconejogador.global_position = posicaocidade[pos_atual]
