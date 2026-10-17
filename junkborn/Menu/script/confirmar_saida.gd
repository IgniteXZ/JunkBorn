extends CanvasLayer

@export var fundo: Control
@export var painel: Control
@export var sim: Button
@export var nao: Button

var _pos: Vector2
var _foco_anterior: Control

func _ready() -> void:
	visible = false
	sim.pressed.connect(get_tree().quit)
	nao.pressed.connect(fechar)



func abrir() -> void:
	if visible:
		return
	_foco_anterior = get_viewport().gui_get_focus_owner()
	visible = true
	_pos = painel.position
	nao.grab_focus()
	_animar(true)

func fechar() -> void:
	await _animar(false)
	visible = false
	painel.position = _pos
	if is_instance_valid(_foco_anterior):
		_foco_anterior.grab_focus()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		fechar()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		(sim if nao.has_focus() else nao).grab_focus()
	elif not (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
		return
	get_viewport().set_input_as_handled()

func _animar(abrindo: bool) -> void:
	var t := create_tween().set_parallel(true)
	var tempo := 0.25 if abrindo else 0.2
	var fora := _pos + Vector2(0, 8)
	if abrindo:
		fundo.modulate.a = 0.0
		painel.position = fora
	t.tween_property(fundo, "modulate:a", 1.0 if abrindo else 0.0, tempo)
	t.tween_property(painel, "position", _pos if abrindo else fora, tempo)
	await t.finished
