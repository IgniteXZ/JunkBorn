extends Node

@export var timeline: String = ""
@export var uma_vez: bool = true
@export var variavel_necessaria: String = ""
@export var jogador: CharacterBody2D

func _ready() -> void:
	if timeline == "":
		return
	if variavel_necessaria != "" and not Dialogic.VAR.get_variable(variavel_necessaria, false):
		return
	var chave := "entrada:" + str(get_path())
	if uma_vez and Global.eventos.get(chave, false):
		return
	_travar(true)
	await get_tree().create_timer(0.6).timeout
	if uma_vez:
		Global.eventos[chave] = true
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	_travar(false)

func _travar(travado: bool) -> void:
	if jogador:
		jogador.pode_mover = not travado
