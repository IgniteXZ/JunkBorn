extends CanvasLayer

@onready var tooltip: PanelContainer = $Tooltip
@onready var tooltip_nome: Label = $Tooltip/Nome

# atalho abrir e fechar inventario
func _process(_delta: float) -> void:
	_atualizar_tooltip()
	
	if get_tree().get_nodes_in_group("minigame_aberto").size() > 0:
		$inventory.visible = false
		return
	
	if Input.is_action_just_pressed("inventory") and Dialogic.VAR.get_variable("liberou_menus", false) and not Global.esta_coleta:
		$inventory.visible = not $inventory.visible

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
func add_item_inventory(ID: int, sprite: Texture, nome: String = "") -> bool:
	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture == null:
			slot.get_node("sprite").texture = sprite
			slot.get_node("amount").text = "1"

			# SALVA O ID NO SLOT (usando metadados do Godot)
			slot.set_meta("item_id", ID)
			

			# guarda o nome ligado à imagem (usado pelo tooltip)
			if nome != "":
				Global.nomes_itens[sprite] = nome

			salvar_inventario()
			return true # Item adicionado com sucesso

	return false

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
	if slot.has_meta("item_id"):
		slot.remove_meta("item_id")

# dados dos itens salvos globalmente (todas cenas)
func salvar_inventario() -> void:
	Global.itens.clear()
	for slot in $inventory/GridContainer.get_children():
		Global.itens.append({
			"sprite": slot.get_node("sprite").texture,
			"amount": slot.get_node("amount").text,
			"item_id": slot.get_meta("item_id") if slot.has_meta("item_id") else -1
		})

# carregar inventario atualizado ao trocar de cena
func carregar_inventario() -> void:
	var slots = $inventory/GridContainer.get_children()

	for i in range(Global.itens.size()):
		if i >= slots.size():
			break

		var dados = Global.itens[i]

		slots[i].get_node("sprite").texture = dados["sprite"]
		slots[i].get_node("amount").text = dados["amount"]

		if dados.has("item_id") and dados["item_id"] != -1:
			slots[i].set_meta("item_id", dados["item_id"])
			
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
