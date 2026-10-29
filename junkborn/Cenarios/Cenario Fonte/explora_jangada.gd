extends Node2D
@export var modo_teste = false
@export var tex_jangada: Texture2D
@onready var area = $testeJangada

var camada_aviso: CanvasLayer
var aviso: Label
var jogador_dentro = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_ao_entrar)
	area.body_exited.connect(_ao_sair)
	
	camada_aviso = CanvasLayer.new()
	camada_aviso.layer = 4
	add_child(camada_aviso)

	aviso = Label.new()
	aviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	aviso.offset_top = -100
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.add_theme_font_size_override("font_size", 24)
	aviso.add_theme_constant_override("outline_size", 8)
	aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	aviso.visible = false
	camada_aviso.add_child(aviso)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not jogador_dentro:
		return

	var c = contar()

	if c["jangada"] >= 1:
		aviso.text = "Aperte E para interagir"
	else:
		aviso.text = "Você precisa de uma jangada para explorar a fonte."

	aviso.visible = true

func _ao_entrar(body):
	if body.is_in_group("player"):
		jogador_dentro = true


func _ao_sair(body):
	if body.is_in_group("player"):
		jogador_dentro = false
		aviso.visible = false

	
func obter_slots() -> Array:
	var slots = []
	var jogador = get_tree().get_first_node_in_group("player")

	if jogador == null:
		return slots

	for no in jogador.find_children("*", "Control", true, false):
		if no.has_method("set_empty_slot"):
			slots.append(no)

	return slots
	
func mesma_textura(a, b) -> bool:
	if a == null or b == null:
		return false
	if a == b:
		return true
	return a.resource_path != "" and a.resource_path == b.resource_path
	
func chave_da_textura(tex) -> String:
	if mesma_textura(tex, tex_jangada):
		return "jangada"
	return ""
	
func contar() -> Dictionary:
	if modo_teste:
		return {"jangada": 1}

	var r = {"jangada": 0}

	for slot in obter_slots():
		var spr = slot.get_node_or_null("sprite")

		if spr == null or spr.texture == null:
			continue

		var chave = chave_da_textura(spr.texture)

		if chave != "":
			r[chave] += 1

	return r
	
func _unhandled_input(event):
	if not jogador_dentro:
		return
	
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		liberar()
		
func liberar():
	$"../colisoes/StaticBody2D/CollisionShape2D".set_deferred("disabled", true)
