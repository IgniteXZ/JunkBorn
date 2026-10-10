extends Area2D

@export var timeline: String = ""
@export var automatico: bool = false
@export var variavel_necessaria: String = ""
@export var timeline_bloqueado: String = ""
@export var cena_destino: String = ""
@export var spawn_destino: String = ""

var _player: Node = null
var _label: Label = null
var _ocupado: bool = false

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area.name != "Interagir":
		return
	_player = area.get_parent()
	if automatico:
		_interagir()
		return
	_label = area.get_node_or_null("LabelInteragir") as Label
	if _label:
		_label.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.name != "Interagir":
		return
	if _label:
		_label.visible = false
	_player = null
	_label = null

func _unhandled_input(event: InputEvent) -> void:
	if automatico or _player == null:
		return
	if event.is_action_pressed("Interagir"):
		get_viewport().set_input_as_handled()
		_interagir()

func _interagir() -> void:
	
	if _ocupado or Dialogic.current_timeline != null:
		return
	if variavel_necessaria != "" and not Dialogic.VAR.get_variable(variavel_necessaria, false):
		await _tocar_dialogo(timeline_bloqueado)
	elif cena_destino != "":
		_ocupado = true
		Global.trocar_cena(cena_destino, spawn_destino)
	else:
		await _tocar_dialogo(timeline)

func _tocar_dialogo(nome: String) -> void:
	if nome == "":
		return
	_ocupado = true
	var jogador := _player
	if _label:
		_label.visible = false
	jogador.pode_mover = false
	Dialogic.start(nome)
	await Dialogic.timeline_ended
	if is_instance_valid(jogador):
		jogador.pode_mover = true
	if _label and _player != null:
		_label.visible = true
	_ocupado = false
