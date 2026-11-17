extends PanelContainer
class_name SlotMaterial

var textura_obrigatoria: Texture2D = null
var quantidade_obrigatoria: int = 0
var quantidade_acumulada: int = 0
var item_colocado_corretamente: bool = false
var eh_apenas_previa: bool = false

@onready var icone_material = _obter_icone()
@onready var texto_quantidade = _obter_texto()
@export var item_data: LixoData = null

func _obter_icone() -> Node:
	var no = get_node_or_null("IconeMaterial")
	if not no: no = get_node_or_null("iconeMaterial")
	if not no: no = find_child("*Icone*", true, false)
	return no

func _obter_texto() -> Node:
	var no = get_node_or_null("textoQuantidade")
	if not no: no = get_node_or_null("TextoQuantidade")
	if not no: no = find_child("*Quantidade*", true, false)
	return no

func setup_slot(textura: Texture2D, qtd_necessaria: int, previa: bool = false) -> void:
	eh_apenas_previa = previa
	textura_obrigatoria = textura
	
	if not icone_material: icone_material = _obter_icone()
	if not texto_quantidade: texto_quantidade = _obter_texto()
	
	if eh_apenas_previa:
		quantidade_obrigatoria = 0
		quantidade_acumulada = qtd_necessaria
		item_colocado_corretamente = true
		if icone_material:
			icone_material.texture = textura
			icone_material.modulate = Color(1, 1, 1, 1)
		if texto_quantidade:
			texto_quantidade.text = str(qtd_necessaria)
	else:
		quantidade_obrigatoria = qtd_necessaria
		quantidade_acumulada = 0
		item_colocado_corretamente = false
		if icone_material:
			icone_material.texture = textura_obrigatoria
			icone_material.modulate = Color(1, 1, 1, 0.8)
		_atualizar_texto_quantidade()

# Catálogo de fallback para itens carregados de slots antigos sem item_data.
# O recurso da origem tem prioridade; não inferimos o ID só pela imagem.
const RECURSOS_CONHECIDOS = [
	preload("res://Resource/Itens/plastico.tres"),
	preload("res://Resource/Itens/metal.tres"),
	preload("res://Resource/Itens/corda.tres"),
	preload("res://Resource/Itens/cano.tres"),
	preload("res://Resource/Itens/garrafaplastica.tres"),
	preload("res://Resource/Itens/picareta.tres"),
	preload("res://Resource/Itens/pa.tres"),
	preload("res://Resource/Itens/jangada.tres"),
	preload("res://Resource/Itens/Panela.tres"),
	preload("res://Resource/Itens/Talheres.tres"),
	preload("res://Resource/Itens/SacolaPlastica.tres"),
	preload("res://Resource/Itens/isopor.tres")
]


func _recurso_por_textura(textura: Texture2D, id_desejado: int = -1) -> LixoData:
	if textura == null:
		return null
	var registrado = Global.dados_por_textura.get(textura, null)
	if registrado is LixoData:
		if id_desejado < 0 or registrado.item_id == id_desejado:
			return registrado
	for candidato in RECURSOS_CONHECIDOS:
		if candidato is LixoData and candidato.textura == textura:
			if id_desejado < 0 or candidato.item_id == id_desejado:
				return candidato
	return null


func _recurso_arrastado(data: Dictionary) -> LixoData:
	for chave in ["item", "item_data"]:
		var candidato = data.get(chave, null)
		if candidato is LixoData:
			return candidato
	var origem = data.get("backup", null)
	if origem is Node and is_instance_valid(origem):
		if "item_data" in origem and origem.item_data is LixoData:
			return origem.item_data
	return _recurso_por_textura(data.get("sprite", null), int(data.get("item_id", -1)))


func _canvas_do_inventario() -> CanvasLayer:
	var atual: Node = self
	while atual != null:
		if "canvass" in atual and atual.canvass is CanvasLayer:
			if atual.canvass.has_method("add_item_inventory"):
				return atual.canvass
		atual = atual.get_parent()
	var encontrado = get_tree().get_first_node_in_group("inventario")
	if encontrado is CanvasLayer and encontrado.has_method("add_item_inventory"):
		return encontrado
	encontrado = get_tree().get_first_node_in_group("InterfaceUsuario")
	if encontrado is CanvasLayer and encontrado.has_method("add_item_inventory"):
		return encontrado
	return null


func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if eh_apenas_previa or not (data is Dictionary):
		return false
	var origem = data.get("backup", null)
	if not (origem is Node) or not is_instance_valid(origem):
		return false
	var textura = data.get("sprite", null)
	if not (textura is Texture2D) or int(data.get("amount", 0)) < 1:
		return false
	# Não aceita sementes/ItemData nem material sem recurso identificável.
	var recurso = _recurso_arrastado(data)
	if recurso == null or recurso.textura != textura:
		return false
	# Bloqueia o drop se o slot já tiver um item diferente acumulado
	if quantidade_acumulada > 0 and item_data != null and item_data.item_id != recurso.item_id:
		return false
	return textura_obrigatoria == null or textura == textura_obrigatoria


func _drop_data(_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(Vector2.ZERO, data):
		return

	if not icone_material: icone_material = _obter_icone()
	if not texto_quantidade: texto_quantidade = _obter_texto()

	var recurso: LixoData = _recurso_arrastado(data)
	var qtd: int = int(data.get("amount", 0))
	if item_data != null and item_data.item_id != recurso.item_id:
		push_warning("Bancada: tente devolver o material antigo antes de colocar outro.")
		return
	item_data = recurso
	quantidade_acumulada += qtd

	if icone_material:
		icone_material.texture = textura_obrigatoria if textura_obrigatoria != null else recurso.textura
		icone_material.modulate = Color.WHITE
	_atualizar_texto_quantidade()

	# O slot de origem é esvaziado pelo _get_drag_data() do inventário.
	# Gravamos o inventário apenas depois que a operação foi aceita.
	var inventario = _canvas_do_inventario()
	if inventario:
		inventario.salvar_inventario()

	_animar_pop()
	_avisar_tela_principal()

func _atualizar_cor_quantidade() -> void:
	if not texto_quantidade or eh_apenas_previa:
		return
	var cor := Color(1, 1, 1, 0.7)
	if item_colocado_corretamente:
		cor = HudEstilo.COR_OK
	elif quantidade_acumulada > 0:
		cor = HudEstilo.COR_TITULO
	texto_quantidade.add_theme_color_override("font_color", cor)

# Slot acende com borda dourada quando o item arrastado encaixa nele
func _notification(what: int) -> void:
	if eh_apenas_previa:
		return
	if what == NOTIFICATION_DRAG_BEGIN:
		var data = null
		if get_viewport().has_method("gui_get_drag_data"):
			data = get_viewport().gui_get_drag_data()
		_destacar(data == null or _can_drop_data(Vector2.ZERO, data))
	elif what == NOTIFICATION_DRAG_END:
		_destacar(false)

func _destacar(ligado: bool) -> void:
	if ligado:
		var sb := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if sb:
			sb.border_color = HudEstilo.COR_TITULO
			add_theme_stylebox_override("panel", sb)
	else:
		remove_theme_stylebox_override("panel")

func _animar_pop() -> void:
	pivot_offset = size / 2.0
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)


func _atualizar_texto_quantidade():
	if texto_quantidade:
		if quantidade_obrigatoria > 0:
			texto_quantidade.text = str(quantidade_acumulada) + "/" + str(quantidade_obrigatoria)
		else:
			texto_quantidade.text = str(quantidade_acumulada)
			
	item_colocado_corretamente = (quantidade_obrigatoria > 0 and quantidade_acumulada >= quantidade_obrigatoria) or (quantidade_obrigatoria == 0 and quantidade_acumulada > 0)
	_atualizar_cor_quantidade()

func consumir_material_forja() -> void:
	quantidade_acumulada = maxi(0, quantidade_acumulada - quantidade_obrigatoria)
	if quantidade_acumulada == 0:
		item_data = null
		if icone_material:
			icone_material.texture = textura_obrigatoria
			icone_material.modulate = Color(1, 1, 1, 0.8)
	_atualizar_texto_quantidade()


func _gui_input(event: InputEvent) -> void:
	if eh_apenas_previa:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if quantidade_acumulada > 0:
			_devolver_itens_ao_inventario()


# Retorna false sem remover nada se o inventário estiver cheio ou o material sem ID.
func _devolver_itens_ao_inventario() -> bool:
	if quantidade_acumulada <= 0:
		return true
	var inventario = _canvas_do_inventario()
	if inventario == null:
		push_warning("Bancada: inventário indisponível; material mantido na bancada.")
		return false

	var recurso: LixoData = item_data
	if recurso == null:
		var textura = textura_obrigatoria
		if textura == null and icone_material:
			textura = icone_material.texture
		recurso = _recurso_por_textura(textura)
	if recurso == null or recurso.textura == null:
		push_warning("Bancada: não foi possível identificar o item; material preservado.")
		return false

	var slots = inventario.get_node_or_null("inventory/GridContainer")
	if slots == null:
		return false
	var cabe: bool = false
	for no in slots.get_children():
		var sprite = no.get_node_or_null("sprite")
		if sprite and (sprite.texture == recurso.textura or sprite.texture == null):
			cabe = true
			break
	if not cabe:
		print("Bancada: inventário cheio; material permanece aqui.")
		return false

	# Snapshot defensivo: caso uma inserção falhe, restauramos o inventário.
	var anterior: Array[Dictionary] = []
	for no in slots.get_children():
		anterior.append({
			"textura": no.get_node("sprite").texture,
			"quantidade": no.get_node("amount").text,
			"recurso": no.item_data,
			"id": int(no.get_meta("item_id", -1)),
			"protegido": bool(no.get_meta("protegido_drone", false))
		})

	for i in range(quantidade_acumulada):
		if not inventario.add_item_inventory(recurso.item_id, recurso.textura, recurso.nome, recurso):
			for j in range(anterior.size()):
				var no = slots.get_child(j)
				var estado = anterior[j]
				no.get_node("sprite").texture = estado["textura"]
				no.get_node("amount").text = estado["quantidade"]
				no.item_data = estado["recurso"]
				if estado["id"] >= 0:
					no.set_meta("item_id", estado["id"])
				elif no.has_meta("item_id"):
					no.remove_meta("item_id")
				no.set_meta("protegido_drone", estado["protegido"])
			inventario.salvar_inventario()
			push_warning("Bancada: falha ao devolver; material preservado.")
			return false

	quantidade_acumulada = 0
	item_data = null
	if icone_material:
		icone_material.texture = textura_obrigatoria
		icone_material.modulate = Color(1, 1, 1, 0.8) if textura_obrigatoria else Color.WHITE
	_atualizar_texto_quantidade()
	_avisar_tela_principal()
	return true


func _avisar_tela_principal():
	var no_atual = get_parent()
	while no_atual != null:
		if no_atual.has_method("verificar_todas_as_receitas"):
			no_atual.verificar_todas_as_receitas()
			break
		no_atual = no_atual.get_parent()
