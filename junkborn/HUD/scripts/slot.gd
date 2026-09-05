extends Control

@export var item_data: LixoData
var drag_backup = null

func _get_drag_data(position: Vector2):
	print("DEBUG DRAG - Conteúdo de item_data no slot: ", item_data)
	if $sprite.texture == null:
		return null
		
	var data := {
		"sprite" : $sprite.texture,
		"amount" : $amount.text,
		"backup" : self,
		"item"   : item_data
	}

	drag_backup = data

	var preview := TextureRect.new()
	preview.texture = $sprite.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(60, 60)

	var preview_container := Control.new()
	preview_container.add_child(preview)
	preview.position = -(preview.size / 2.0)

	set_empty_slot()
	set_drag_preview(preview_container)

	return data

func set_empty_slot() -> void:
	$sprite.texture = null
	$amount.text = ""
	item_data = null

func _can_drop_data(position: Vector2, data) -> bool:
	return data != null and data.has("sprite") and data["sprite"] != null

func _drop_data(position: Vector2, data) -> void:
	if $sprite.texture == data.sprite:
		var drop_item = int($amount.text)
		drop_item += int(data.amount)
		$amount.text = str(drop_item)
		if item_data == null and "item" in data:
			item_data = data["item"]
	else:
		data.backup.get_node("sprite").texture = $sprite.texture
		data.backup.get_node("amount").text = $amount.text
		if "item_data" in data.backup:
			data.backup.item_data = item_data
		
		$sprite.texture = data.sprite
		$amount.text = data.amount
		if "item" in data:
			item_data = data["item"]
			
	if has_node("../../..") and get_node("../../..").has_method("salvar_inventario"):
		get_node("../../..").salvar_inventario()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful() and drag_backup != null:
			$sprite.texture = drag_backup["sprite"]
			$amount.text = drag_backup["amount"]
			if "item" in drag_backup:
				item_data = drag_backup["item"]
			if has_node("../../..") and get_node("../../..").has_method("salvar_inventario"):
				get_node("../../..").salvar_inventario()

		drag_backup = null
