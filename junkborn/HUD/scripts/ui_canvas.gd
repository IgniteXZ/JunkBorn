extends CanvasLayer



#atalho abrir e fechar inventario
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		$inventory.visible = not $inventory.visible
		
func _ready() -> void:
	carregar_inventario()

#coletar item no chão
func add_item_inventory(sprite: Texture) -> bool:
	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture == null:
			slot.get_node("sprite").texture = sprite
			slot.get_node("amount").text = "1"
			

			salvar_inventario()
			return true
			
	return false

#dados dos itens salvos globalmente (todas cenas)
func salvar_inventario() -> void:

	Global.itens.clear()
	for slot in $inventory/GridContainer.get_children():
		Global.itens.append({
			"sprite": slot.get_node("sprite").texture,
			"amount": slot.get_node("amount").text
		})
		
		

#carregar inventario atualizado ao trocar de cena
func carregar_inventario() -> void:
	
	var slots = $inventory/GridContainer.get_children()
	
	for i in range (Global.itens.size()):
		if i >= slots.size():
			break
			
		var dados = Global.itens[i]
		
		slots[i].get_node("sprite").texture = dados["sprite"]
		slots[i].get_node("amount").text = dados["amount"]
		

	
