class_name Escavavel
extends Area2D

 
enum Tipo { DESENTERRAR, MINERAR }
 
@export var tipo: Tipo = Tipo.DESENTERRAR
## O TileMapLayer de onde os tiles serão apagados.
@export var camada: TileMapLayer
## A imagem da ferramenta (a mesma que aparece no inventário: pá ou picareta).
@export var tex_ferramenta: Texture2D
## Os itens (ItemnoChao) que ficam escondidos até o tile sumir.
@export var sementes: Array[Area2D] = []
## Distância (em pixels) além do retângulo em que o aviso já aparece.
@export var distancia: float = 24.0
 
var _rects: Array[Rect2] = []
var _id: String = ""
var _feito := false
var _jogador: Node2D
var _cache_tem := false
var _espera := 0.0
 
var _camada_aviso: CanvasLayer
var _aviso: Label
 
 
func _ready() -> void:
	# Este Area2D só serve para desenhar os retângulos no editor.
	monitoring = false
	monitorable = false
 
	_id = "escavado:" + str(get_path())
	_coletar_retangulos()
	_criar_aviso()
 
	if Global.itens_coletados.has(_id):
		# Já foi escavado antes (voltou para a cena)
		_feito = true
		_apagar_tiles()
		_liberar_sementes()
	else:
		_esconder_sementes()
 
 
func _process(delta: float) -> void:
	if _feito:
		return
 
	if not is_instance_valid(_jogador):
		_jogador = get_tree().get_first_node_in_group("player") as Node2D
		if _jogador == null:
			return
 
	if not _esta_perto(_jogador.global_position):
		if _aviso.visible:
			_aviso.visible = false
		return
 
	# Confere o inventário só a cada 0.2s (é leve, mas não precisa ser todo frame)
	_espera -= delta
	if _espera <= 0.0:
		_espera = 0.2
		_cache_tem = _tem_ferramenta()
 
	_aviso.text = "[E] para interagir" if _cache_tem else _texto_sem_ferramenta()
	_aviso.visible = true
 
	if Input.is_action_just_pressed("Interagir") and _tem_ferramenta():
		_executar()
 
 
func _texto_sem_ferramenta() -> String:
	if tipo == Tipo.DESENTERRAR:
		return "Você precisa de uma pá para desenterrar."
	return "Você precisa de uma picareta para quebrar a pedra."
 
 
# ---------------------------------------------------------------
# ÁREA
# ---------------------------------------------------------------
 
func _coletar_retangulos() -> void:
	for filho in get_children():
		var forma := filho as CollisionShape2D
		if forma and forma.shape is RectangleShape2D:
			var tam: Vector2 = (forma.shape as RectangleShape2D).size * forma.global_scale.abs()
			_rects.append(Rect2(forma.global_position - tam / 2.0, tam))
 
 
func _esta_perto(pos: Vector2) -> bool:
	for r in _rects:
		if r.grow(distancia).has_point(pos):
			return true
	return false
 
 
# ---------------------------------------------------------------
# INVENTÁRIO (lê pelo sprite do slot, como na forja e nos canos)
# ---------------------------------------------------------------
 
func _tem_ferramenta() -> bool:
	if tex_ferramenta == null:
		return false
 
	var raiz: Node = get_tree().get_first_node_in_group("inventario")
	if raiz == null:
		raiz = _jogador
	if raiz == null:
		return false
 
	for no in raiz.find_children("*", "Control", true, false):
		if not no.has_method("set_empty_slot"):
			continue
		var spr = no.get_node_or_null("sprite")
		if spr and _mesma_textura(spr.texture, tex_ferramenta):
			return true
	return false
 
 
func _mesma_textura(a: Texture2D, b: Texture2D) -> bool:
	if a == null or b == null:
		return false
	if a == b:
		return true
	return a.resource_path != "" and a.resource_path == b.resource_path
 
 
# ---------------------------------------------------------------
# AÇÃO
# ---------------------------------------------------------------
 
func _executar() -> void:
	_feito = true
	_aviso.visible = false
	_apagar_tiles()
	_liberar_sementes()
 
	if not Global.itens_coletados.has(_id):
		Global.itens_coletados.append(_id)
 
	# Tremidinha de câmera, se a câmera tiver a função "tremer"
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("tremer"):
		cam.tremer(3.0)
 
 
func _apagar_tiles() -> void:
	if camada == null:
		push_warning("Escavavel '%s': arraste um TileMapLayer para 'Camada' no Inspetor." % name)
		return
 
	for celula in camada.get_used_cells():
		var centro := camada.to_global(camada.map_to_local(celula))
		for r in _rects:
			if r.has_point(centro):
				camada.erase_cell(celula)
				break
 
 
func _esconder_sementes() -> void:
	for s in sementes:
		if is_instance_valid(s):
			s.visible = false
			s.process_mode = Node.PROCESS_MODE_DISABLED
 
 
func _liberar_sementes() -> void:
	for s in sementes:
		if is_instance_valid(s):
			s.visible = true
			s.process_mode = Node.PROCESS_MODE_INHERIT
 
 
# ---------------------------------------------------------------
# AVISO NA TELA (mesmo estilo do aviso dos canos)
# ---------------------------------------------------------------
 
func _criar_aviso() -> void:
	_camada_aviso = CanvasLayer.new()
	_camada_aviso.layer = 4
	add_child(_camada_aviso)
 
	_aviso = Label.new()
	_aviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_aviso.offset_top = -100
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.add_theme_font_size_override("font_size", 24)
	_aviso.add_theme_constant_override("outline_size", 8)
	_aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	_aviso.visible = false
	_camada_aviso.add_child(_aviso)
 
