
extends Node2D

@export var especie: String = ""

const TEXTURAS = {
	"fonte_semente_1": preload("res://Resource/Itens/sementeEspada.png"),
	"deserto1_semente2": preload("res://Resource/Itens/sementeSaman.png"),
	"deserto2_semente5": preload("res://Resource/Itens/sementeGiras.png"),
	"mina_semente3": preload("res://Resource/Itens/sementeAguap.png"),
	"pantano_semente_4": preload("res://Resource/Itens/sementeOrapro.png")
}

func _ready() -> void:
	var textura: Texture2D = TEXTURAS.get(especie)

	if textura == null:
		push_warning("Planta sem textura: " + especie)
		return

	var sprite = Sprite2D.new()
	sprite.texture = textura
	sprite.position = Vector2(0, -14)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	add_child(sprite)
