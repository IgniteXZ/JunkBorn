extends Control

const LARGURA := 420.0   # largura do post-it aberto (era 520)
const PEEK := 60.0
const MARGEM := 8.0
const DURACAO_AVISO := 3500
const TAM_TITULO := 24
const TAM_DESC := 18     # descrição maior (era 16)

@onready var papel: PanelContainer = $Papel
@onready var texto: RichTextLabel = $Papel/Texto
@onready var aba: Label = $Aba

var _hover: bool = false
var _fixado: bool = false
var _aberto: bool = false
var _tween: Tween
var _ultimo: String = ""
var _aviso_pendente: bool = false
var _aviso_ate: int = 0
var _novas: Dictionary = {}       # missão -> ms em que o "NOVA!" some (-1 = ainda não mostrado)
var _concluidas: Dictionary = {}  # missão -> ms em que o risco some (-1 = ainda não mostrado)

func _ready() -> void:
	papel.custom_minimum_size.x = LARGURA
	papel.get_theme_stylebox("panel").content_margin_right = PEEK + 14.0
	aba.position = Vector2(LARGURA - PEEK, 10)
	aba.size.x = PEEK
	position.x = _x_recolhido()
	papel.mouse_entered.connect(func(): _hover = true)
	papel.mouse_exited.connect(func(): _hover = false)
	GerenciadorMissoes.missao_adicionada.connect(_on_missao_adicionada)
	GerenciadorMissoes.missao_concluida.connect(_on_missao_concluida)

func _process(_delta: float) -> void:
	var agora: int = Time.get_ticks_msec()
	_limpar(_novas, agora)
	_limpar(_concluidas, agora)

	var todas: Array = GerenciadorMissoes.missoes_ativas
	var visiveis: Array = todas.filter(func(m): return not m.concluida or _concluidas.has(m))
	var pendentes: int = todas.filter(func(m): return not m.concluida).size()

	var ocupado: bool = Dialogic.current_timeline != null or not get_tree().get_nodes_in_group("minigame_aberto").is_empty()
	var mostrar: bool = not visiveis.is_empty() and not ocupado
	if visible != mostrar:
		visible = mostrar
	if not mostrar:
		_hover = false
		if _aberto:
			_aberto = false
			_animar()
		return

	if _aviso_pendente:
		_aviso_pendente = false
		_aviso_ate = agora + DURACAO_AVISO
		_iniciar_prazos(_novas, agora)
		_iniciar_prazos(_concluidas, agora)
		_pulsar()

	aba.text = str(pendentes)
	var novo: String = _montar_texto(visiveis)
	if novo != _ultimo:
		_ultimo = novo
		_atualizar_texto(novo)

	if Input.is_action_just_pressed("Missoes"):
		_fixado = not _fixado

	var deve_abrir: bool = _hover or _fixado or agora < _aviso_ate
	if deve_abrir != _aberto:
		_aberto = deve_abrir
		_animar()

func _on_missao_adicionada(missao: MissaoR) -> void:
	_novas[missao] = -1
	_aviso_pendente = true

func _on_missao_concluida(missao: MissaoR) -> void:
	_concluidas[missao] = -1
	_novas.erase(missao)
	_aviso_pendente = true

func _iniciar_prazos(d: Dictionary, agora: int) -> void:
	for m in d.keys():
		if d[m] < 0:
			d[m] = agora + DURACAO_AVISO

func _limpar(d: Dictionary, agora: int) -> void:
	for m in d.keys():
		if d[m] >= 0 and d[m] <= agora:
			d.erase(m)

func _montar_texto(lista: Array) -> String:
	var t: String = ""
	for m in lista:
		if _concluidas.has(m):
			t += "[color=#8a7a4a][s][font_size=%d]%s[/font_size]\n[font_size=%d]%s[/font_size][/s][/color]\n\n" % [TAM_TITULO, m.titulo, TAM_DESC, m.descricao]
		else:
			var tag: String = "[color=#d03030]NOVA! [/color]" if _novas.has(m) else ""
			t += "[font_size=%d]%s[color=#a6591a]%s[/color][/font_size]\n[font_size=%d]%s[/font_size]\n\n" % [TAM_TITULO, tag, m.titulo, TAM_DESC, m.descricao]
	return t.strip_edges()

func _atualizar_texto(novo: String) -> void:
	texto.text = novo
	await get_tree().process_frame
	papel.reset_size()

func _pulsar() -> void:
	aba.pivot_offset = aba.size / 2.0
	var t: Tween = create_tween().set_loops(3)
	t.tween_property(aba, "scale", Vector2(1.5, 1.5), 0.15)
	t.tween_property(aba, "scale", Vector2.ONE, 0.25)

func _x_recolhido() -> float:
	return -(LARGURA - PEEK)

func _animar() -> void:
	var alvo: float = MARGEM if _aberto else _x_recolhido()
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:x", alvo, 0.2)
