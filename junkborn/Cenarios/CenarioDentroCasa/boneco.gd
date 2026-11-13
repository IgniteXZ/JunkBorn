extends TileMapLayer

const BONECO = preload("res://Resource/Itens/boneco.tres")
const ID_BONECO := 100


func _ready() -> void:
	# Se Filomeno ja coletou o boneco, ele nao aparece novamente
	if Dialogic.VAR.get_variable("Filomeno_estacoComBoneco", false):
		queue_free()
		return

	Dialogic.signal_event.connect(_on_dialogic_signal)



func _on_dialogic_signal(argument: String) -> void:
	if argument == "pegou_boneco":
		var inventario = get_tree().get_first_node_in_group("inventario")

		if inventario:
			if inventario.add_item_inventory(ID_BONECO, BONECO.textura, "Boneco de palha"):
				queue_free()
			else:
				print("Inventário cheio!")
