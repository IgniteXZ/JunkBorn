extends CanvasLayer

#atalho abrir e fechar inventario
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		$inventory.visible = not $inventory.visible

#coletar item no chão
func add_item_inventory(sprite: Texture) -> bool:
	for slot in $inventory/GridContainer.get_children():
		if slot.get_node("sprite").texture == null:
			slot.get_node("sprite").texture = sprite
			slot.get_node("amount").text = "1"
			return true
			
	return false
