extends CanvasLayer

# atalho abrir e fechar inventario
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		$inventory.visible = not $inventory.visible

func _ready() -> void:
	carregar_inventario()

# coletar item no chão
func add_item_inventory(ID: int, sprite: Texture) -> bool:
	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture == null:
			slot.get_node("sprite").texture = sprite
			slot.get_node("amount").text = "1"

			# SALVA O ID NO SLOT (usando metadados do Godot)
			slot.set_meta("item_id", ID)

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
