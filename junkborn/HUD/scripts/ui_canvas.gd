extends CanvasLayer

@onready var tooltip: PanelContainer = $Tooltip
@onready var tooltip_nome: Label = $Tooltip/Nome

# atalho abrir e fechar inventario

func _process(_delta: float) -> void:
	_atualizar_tooltip()

	# Fecha as interfaces automaticamente durante minigames
	if Global.esta_coleta or not get_tree().get_nodes_in_group("minigame_aberto").is_empty():
		$inventory.hide()
		$inventory/ui_livro/Livro.hide()
		$inventory/ui_livro/Livro2.hide()
		$"../CanvaMapa/Mapa".hide()
		return

	# Abre e fecha normalmente fora dos minigames
	if Input.is_action_just_pressed("inventory") and Dialogic.VAR.get_variable("liberou_menus", false):
		$inventory.visible = not $inventory.visible

		if $inventory.visible:
			$"../CanvaMapa/Mapa".hide()
			$inventory/ui_livro/Livro.hide()
			$inventory/ui_livro/Livro2.hide()

			
func _ready() -> void:
	add_to_group("inventario")
	carregar_inventario()
	
	
func _atualizar_tooltip() -> void:
	var nome := ""
	if $inventory.visible and not get_viewport().gui_is_dragging():
		for slot in $inventory/GridContainer.get_children():
			if slot.get_global_rect().has_point(slot.get_global_mouse_position()):
				nome = Global.nomes_itens.get(slot.get_node("sprite").texture, "")
				break
	tooltip.visible = nome != ""
	if tooltip.visible:
		tooltip_nome.text = nome
		tooltip.reset_size()
		tooltip.position = tooltip.get_global_mouse_position() + Vector2(16, 16)

# coletar item no chão

func add_item_inventory(ID: int, sprite: Texture, nome: String = "", dados: Resource = null) -> bool:
	var slots = $inventory/GridContainer.get_children()

	# Guarda o nome para o tooltip
	if nome != "":
		Global.nomes_itens[sprite] = nome

	# PRIMEIRO: procura um item igual
	for slot in slots:
		if slot.get_node("sprite").texture == sprite:
			var quantidade = int(slot.get_node("amount").text)
			slot.get_node("amount").text = str(quantidade + 1)
			if dados != null and slot.item_data == null:
				slot.item_data = dados

			salvar_inventario()
			return true

	# SEGUNDO: se não encontrou, procura um slot vazio
	for slot in slots:
		if slot.get_node("sprite").texture == null:
			slot.get_node("sprite").texture = sprite
			slot.get_node("amount").text = "1"
			slot.set_meta("item_id", ID)
			slot.item_data = dados

			salvar_inventario()
			return true

	return false




# Apaga todos os itens do inventário e sincroniza o estado global.
func limpar_inventario_completo() -> void:
	$inventory.hide()
	$inventory/ui_livro/Livro.hide()
	$inventory/ui_livro/Livro2.hide()
	$"../CanvaMapa/Mapa".hide()

	for slot in $inventory/GridContainer.get_children():
		limpar_slot(slot)
	salvar_inventario()


# Mostra um aviso fofo após a penalidade do drone.
func mostrar_mensagem_perda() -> void:
	var overlay := Control.new()
	overlay.name = "MensagemPerdaItens"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	overlay.modulate.a = 0.0
	add_child(overlay)

	var painel := PanelContainer.new()
	painel.custom_minimum_size = Vector2(480, 124)
	painel.set_anchors_preset(Control.PRESET_CENTER)
	painel.offset_left = -240
	painel.offset_top = -62
	painel.offset_right = 240
	painel.offset_bottom = 62

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.16, 0.075, 0.18, 0.96)
	estilo.border_color = Color(1.0, 0.58, 0.82, 1.0)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(18)
	estilo.shadow_color = Color(0.04, 0.02, 0.08, 0.55)
	estilo.shadow_size = 12
	painel.add_theme_stylebox_override("panel", estilo)
	overlay.add_child(painel)

	var texto := Label.new()
	texto.text = "♡ A-Ah... o drone te pegou! ♡\nVocê perdeu todos os seus itens..."
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_color_override("font_color", Color(1.0, 0.82, 0.93, 1.0))
	texto.add_theme_color_override("font_outline_color", Color(0.20, 0.07, 0.18, 1.0))
	texto.add_theme_constant_override("outline_size", 3)
	texto.add_theme_font_size_override("font_size", 21)
	painel.add_child(texto)

	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.25)
	tween.tween_interval(2.8)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.4)
	tween.tween_callback(overlay.queue_free)

# remove um item específico pelo ID
func remover_item_por_id(ID: int) -> bool:
	for slot in $inventory/GridContainer.get_children():
		if slot.has_meta("item_id") and slot.get_meta("item_id") == ID:
			limpar_slot(slot)
			salvar_inventario()
			return true # Achou e removeu

	return false # Não achou nenhum item com esse ID

# remove um item aleatório do inventário (só entre os slots ocupados)
func remover_item_aleatorio() -> bool:
	var slots_ocupados: Array = []

	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture != null:
			slots_ocupados.append(slot)
			

	if slots_ocupados.is_empty():
		return false # Inventário vazio, nada pra remover

	var slot_escolhido = slots_ocupados[randi() % slots_ocupados.size()]
	limpar_slot(slot_escolhido)
	salvar_inventario()
	return true

# função auxiliar: limpa um slot (sprite, texto e meta do ID)
func limpar_slot(slot: Node) -> void:
	slot.get_node("sprite").texture = null
	slot.get_node("amount").text = ""
	if "item_data" in slot:
		slot.item_data = null
	if slot.has_meta("item_id"):
		slot.remove_meta("item_id")

# dados dos itens salvos globalmente (todas cenas)
func salvar_inventario() -> void:
	Global.itens.clear()
	for slot in $inventory/GridContainer.get_children():
		Global.itens.append({
			"sprite": slot.get_node("sprite").texture,
			"amount": slot.get_node("amount").text,
			"item_id": slot.get_meta("item_id") if slot.has_meta("item_id") else -1,
			"item_data": slot.item_data
		})


func carregar_inventario() -> void:
	var slots = $inventory/GridContainer.get_children()

	for i in range(Global.itens.size()):
		if i >= slots.size():
			break

		var dados = Global.itens[i]

		slots[i].get_node("sprite").texture = dados["sprite"]
		slots[i].get_node("amount").text = dados["amount"]
		slots[i].item_data = dados.get("item_data", null)

		if dados.has("item_id") and dados["item_id"] != -1:
			slots[i].set_meta("item_id", dados["item_id"])
		
# Adicione esta função no script do seu Inventário (ex: ui_canvas.gd)
# Remove TODAS as sementes (qualquer item com tipo "semente") e devolve um Array
# com o item_data repetido uma vez por unidade.
func remover_todas_as_sementes() -> Array:
	var sementes: Array = []

	for slot in $inventory/GridContainer.get_children():
		var dados = slot.item_data
		if slot.get_node("sprite").texture != null:
			print("[INV] slot com item | item_data: ", dados, " | tipo: ", dados.tipo if dados else "SEM DADOS")
		if dados == null or dados.tipo != "semente":
			continue
		# ... resto igual

		var texto: String = slot.get_node("amount").text
		var qtd: int = int(texto) if texto != "" else 1
		for i in range(qtd):
			sementes.append(dados)

		limpar_slot(slot)

	if not sementes.is_empty():
		salvar_inventario()

	return sementes

# carregar inventario atualizado ao trocar de cena

			
# Remove do inventário todos os itens com essa textura e devolve a quantidade total
func remover_itens_por_textura(textura: Texture2D) -> int:
	var total := 0
	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture == textura:
			var qtd: String = slot.get_node("amount").text
			total += int(qtd) if qtd != "" else 1
			limpar_slot(slot)
	if total > 0:
		salvar_inventario()
	return total
