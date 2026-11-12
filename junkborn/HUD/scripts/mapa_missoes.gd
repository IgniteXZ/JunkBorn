extends Control


@onready var imagem_mapa: TextureRect = get_parent() as TextureRect
@onready var mapa: Control = get_parent().get_parent() as Control

var _botoes: Dictionary = {}     
var _grupos: Dictionary = {}     
var _estado_anterior: String = ""
var _janela: AcceptDialog


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_janela = AcceptDialog.new()
	_janela.title = "Objetivos do mapa"
	_janela.ok_button_text = "Fechar"
	add_child(_janela)

	GerenciadorMissoes.missao_adicionada.connect(_on_missao_alterada)
	GerenciadorMissoes.missao_concluida.connect(_on_missao_alterada)
	mapa.visibility_changed.connect(_verificar_alteracoes)
	imagem_mapa.resized.connect(_posicionar_marcadores)
	_verificar_alteracoes()


func _process(_delta: float) -> void:
  
	if is_visible_in_tree():
		_verificar_alteracoes()


func _on_missao_alterada(_missao: MissaoR) -> void:
	_verificar_alteracoes()


func _estado() -> String:
	var partes: PackedStringArray = []
	for missao in GerenciadorMissoes.missoes_ativas:
		if missao == null:
			continue
		partes.append(missao.id_missao + ":" + str(missao.concluida))
		for destino in missao.destinos_mapa:
			if destino == null:
				continue
			partes.append(str(destino.regiao_id) + ":" + destino.id_item_coletado + ":" + str(Global.itens_coletados.has(destino.id_item_coletado)))
	return "|".join(partes)


func _verificar_alteracoes() -> void:
	var estado_atual: String = _estado()
	if estado_atual == _estado_anterior:
		return
	_estado_anterior = estado_atual
	_reconstruir_marcadores()


func _reconstruir_marcadores() -> void:
	for botao in _botoes.values():
		botao.queue_free()
	_botoes.clear()
	_grupos.clear()

	var pontos: Array = mapa.get("posicaocidade")

	for missao in GerenciadorMissoes.missoes_ativas:
		if missao == null or missao.concluida:
			continue
		for destino in missao.destinos_mapa:
			if destino == null:
				continue
			if destino.regiao_id < 0 or destino.regiao_id >= pontos.size():
				continue
			if destino.id_item_coletado != "" and Global.itens_coletados.has(destino.id_item_coletado):
				continue

			var regiao: int = destino.regiao_id
			if not _grupos.has(regiao):
				_grupos[regiao] = []
			_grupos[regiao].append({
				"missao": missao.titulo,
				"destino": destino.titulo,
				"descricao": missao.descricao
			})

	for regiao in _grupos.keys():
		var botao := Button.new()
		botao.text = "!" if _grupos[regiao].size() == 1 else str(_grupos[regiao].size())
		botao.custom_minimum_size = Vector2(34, 34)
		botao.size = Vector2(34, 34)
		botao.focus_mode = Control.FOCUS_NONE
		botao.mouse_filter = Control.MOUSE_FILTER_STOP
		botao.tooltip_text = _texto_do_marcador(regiao)
		botao.add_theme_font_size_override("font_size", 19)
		botao.add_theme_color_override("font_color", Color(0.20, 0.13, 0.04))
		botao.add_theme_color_override("font_hover_color", Color(0.20, 0.13, 0.04))
		botao.add_theme_color_override("font_pressed_color", Color(0.20, 0.13, 0.04))
		botao.add_theme_stylebox_override("normal", _estilo(Color(0.98, 0.76, 0.25)))
		botao.add_theme_stylebox_override("hover", _estilo(Color(1.0, 0.87, 0.44)))
		botao.add_theme_stylebox_override("pressed", _estilo(Color(0.85, 0.62, 0.17)))
		botao.pressed.connect(_abrir_detalhes.bind(regiao))
		add_child(botao)
		_botoes[regiao] = botao

	_posicionar_marcadores()


func _estilo(cor: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor
	estilo.border_color = Color(0.29, 0.19, 0.07)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(17)
	return estilo


func _posicionar_marcadores() -> void:
	if imagem_mapa == null or imagem_mapa.texture == null:
		return
	var pontos: Array = mapa.get("posicaocidade")
	var tamanho_textura: Vector2 = imagem_mapa.texture.get_size()
	var escala: float = minf(imagem_mapa.size.x / tamanho_textura.x, imagem_mapa.size.y / tamanho_textura.y)
	var tamanho_imagem: Vector2 = tamanho_textura * escala
	var margem: Vector2 = (imagem_mapa.size - tamanho_imagem) / 2.0
	var sobrepostos: Dictionary = {}

	for regiao in _botoes.keys():
		if regiao < 0 or regiao >= pontos.size():
			continue
		var pos: Vector2 = margem + tamanho_imagem * pontos[regiao]

		var chave: String = str(roundi(pos.x / 18.0)) + ":" + str(roundi(pos.y / 18.0))
		var repeticao: int = int(sobrepostos.get(chave, 0))
		sobrepostos[chave] = repeticao + 1
		var deslocamento: Vector2 = Vector2(repeticao * 37.0, -26.0)
		var botao: Button = _botoes[regiao]
		botao.position = pos + deslocamento - Vector2(17, 17)


func _texto_do_marcador(regiao: int) -> String:
	var linhas: PackedStringArray = []
	for objetivo in _grupos.get(regiao, []):
		linhas.append("%s — %s" % [objetivo["missao"], objetivo["destino"]])
	return "\n".join(linhas)


func _abrir_detalhes(regiao: int) -> void:
	var linhas: PackedStringArray = []
	for objetivo in _grupos.get(regiao, []):
		linhas.append("MISSÃO: " + str(objetivo["missao"]))
		linhas.append("DESTINO: " + str(objetivo["destino"]))
		linhas.append(str(objetivo["descricao"]))
		linhas.append("")
	_janela.dialog_text = "\n".join(linhas).strip_edges()
	_janela.popup_centered(Vector2i(460, 240))
