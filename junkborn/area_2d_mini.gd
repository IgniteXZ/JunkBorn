extends Area2D

var perto: bool = false
@export var mini_game_coleta: Node2D
@export var jogador: CharacterBody2D

var _label_interagir: Label = null


func _process(_delta: float) -> void:
	if not perto or Global.esta_coleta or Dialogic.current_timeline != null:
		return
	if Input.is_action_just_pressed("Interagir"):
		if mini_game_coleta == null or jogador == null:
			return
		if _label_interagir != null:
			_label_interagir.hide()
		mini_game_coleta.show()
		jogador.pode_mover = false
		Global.esta_coleta = true


func _on_mini_game_coleta_fechar_coleta() -> void:
	if mini_game_coleta != null:
		mini_game_coleta.hide()
	if jogador != null:
		jogador.pode_mover = true
	Global.esta_coleta = false
	if perto and _label_interagir != null:
		_label_interagir.show()


func _on_area_entered(area: Area2D) -> void:
	if area.name != "Interagir":
		return
	perto = true
	_label_interagir = area.get_node_or_null("LabelInteragir") as Label
	if _label_interagir != null and not Global.esta_coleta:
		_label_interagir.show()


func _on_area_exited(area: Area2D) -> void:
	if area.name != "Interagir":
		return
	perto = false
	if _label_interagir != null:
		_label_interagir.hide()
	_label_interagir = null
