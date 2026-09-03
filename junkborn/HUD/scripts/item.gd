extends Area2D

var perto: bool = false
var player: Area2D = null

@export var labelinteragir: Label
var canva = null
var canvass: CanvasLayer




var MissaoTeste = preload("res://Resource/MissaoTeste.tres")
var MissaoDebug = preload("res://Resource/MissaoLegal.tres")


func _process(delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		print("CANVAS: ", canvass)

		if canvass.add_item_inventory($sprite.texture):
			labelinteragir.visible = false
			queue_free()
		pass
		
	if perto:
		GerenciadorMissoes.adicionar_missao(MissaoTeste)
		GerenciadorMissoes.adicionar_missao(MissaoDebug)
			


func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area
	labelinteragir.visible = true


func _on_area_exited(area: Area2D) -> void:
	perto = false
	player = null
	labelinteragir.visible = false


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
