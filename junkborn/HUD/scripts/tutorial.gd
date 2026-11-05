extends CanvasLayer

const FONTE: Font = preload("res://Fonte/PressStart2P.ttf")
const TAM_FONTE: int = 16
const MARGEM_BAIXO: float = 70.0

@onready var caixa: PanelContainer = $Caixa
@onready var linhas: VBoxContainer = $Caixa/Linhas

var _ocupado: bool = false

func _ready() -> void:
	caixa.modulate.a = 0.0
	visible = false

func mostrar(id: String, mensagem: String, acoes: String = "", duracao: float = 8.0) -> void:
	var chave: String = "tutorial_" + id
	if Global.eventos.get(chave, false):
		return
	Global.eventos[chave] = true
	_exibir(mensagem, acoes.split(" ", false), duracao)

func _exibir(mensagem: String, acoes: PackedStringArray, duracao: float) -> void:
	while _ocupado or Dialogic.current_timeline != null or not get_tree().get_nodes_in_group("minigame_aberto").is_empty():
		await get_tree().process_frame
	_ocupado = true

	_montar(mensagem)
	await get_tree().process_frame
	caixa.reset_size()
	_posicionar()
	visible = true
	create_tween().tween_property(caixa, "modulate:a", 1.0, 0.4)

	var fim: int = Time.get_ticks_msec() + int(duracao * 1000)
	while Time.get_ticks_msec() < fim:
		for a in acoes:
			if Input.is_action_just_pressed(a):
				fim = 0
		await get_tree().process_frame

	var t: Tween = create_tween()
	t.tween_property(caixa, "modulate:a", 0.0, 0.4)
	await t.finished
	visible = false
	_ocupado = false

func _posicionar() -> void:
	var tela: Vector2 = get_viewport().get_visible_rect().size
	caixa.position = Vector2((tela.x - caixa.size.x) / 2.0, tela.y - caixa.size.y - MARGEM_BAIXO)
	
func _montar(mensagem: String) -> void:
	for filho in linhas.get_children():
		linhas.remove_child(filho)
		filho.queue_free()
	var regex: RegEx = RegEx.create_from_string("<(\\w+)>")
	for texto_linha in mensagem.replace("|", "\n").split("\n"):
		var linha: HBoxContainer = HBoxContainer.new()
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		linha.add_theme_constant_override("separation", 8)
		linhas.add_child(linha)
		var pos: int = 0
		for m in regex.search_all(texto_linha):
			_add_texto(linha, texto_linha.substr(pos, m.get_start() - pos))
			_add_tecla(linha, m.get_string(1))
			pos = m.get_end()
		_add_texto(linha, texto_linha.substr(pos))

func _add_texto(linha: HBoxContainer, t: String) -> void:
	t = t.strip_edges()
	if t == "":
		return
	var lbl: Label = Label.new()
	lbl.text = t
	lbl.add_theme_font_override("font", FONTE)
	lbl.add_theme_font_size_override("font_size", TAM_FONTE)
	linha.add_child(lbl)

func _add_tecla(linha: HBoxContainer, acao: String) -> void:
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color("#f0f0f0")
	estilo.border_color = Color("#6b6b6b")
	estilo.set_border_width_all(2)
	estilo.border_width_bottom = 6   # dá o relevo de tecla
	estilo.content_margin_left = 10
	estilo.content_margin_right = 10
	estilo.content_margin_top = 6
	estilo.content_margin_bottom = 12

	var tecla: PanelContainer = PanelContainer.new()
	tecla.custom_minimum_size = Vector2(44, 44)
	tecla.add_theme_stylebox_override("panel", estilo)

	var lbl: Label = Label.new()
	lbl.text = _nome_tecla(acao)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", FONTE)
	lbl.add_theme_font_size_override("font_size", TAM_FONTE)
	lbl.add_theme_color_override("font_color", Color("#202020"))
	tecla.add_child(lbl)

	linha.add_child(tecla)
	_pulsar(tecla)

func _nome_tecla(acao: String) -> String:
	for ev in InputMap.action_get_events(acao):
		var tecla_ev: InputEventKey = ev as InputEventKey
		if tecla_ev:
			var k: Key = tecla_ev.physical_keycode if tecla_ev.physical_keycode != 0 else tecla_ev.keycode
			return OS.get_keycode_string(k).to_upper()
	return acao.to_upper()

func _pulsar(tecla: Control) -> void:
	await get_tree().process_frame
	if not is_instance_valid(tecla):
		return
	tecla.pivot_offset = tecla.size / 2.0
	var t: Tween = tecla.create_tween().set_loops()
	t.tween_property(tecla, "scale", Vector2(1.12, 1.12), 0.5)
	t.tween_property(tecla, "scale", Vector2.ONE, 0.5)
