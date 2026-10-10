extends Node

@export var timeline: String = ""
@export var variavel_visto: String = ""
@export var jogador: CharacterBody2D

func _ready() -> void:
	if timeline == "":
		return
	if variavel_visto != "" and Dialogic.VAR.get_variable(variavel_visto, false):
		return
	_travar(true)
	await get_tree().create_timer(0.6).timeout
	if variavel_visto != "":
		Dialogic.VAR.set_variable(variavel_visto, true)
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	_travar(false)

func _travar(travado: bool) -> void:
	if jogador:
		jogador.pode_mover = not travado
