
extends Node2D

@export var especie: String = ""

const TEXTURAS = {
	"fonte_semente_1": preload("res://HUD/sprites/plante.png"),
	"deserto1_semente2": preload("res://HUD/sprites/plante.png"),
	"deserto2_semente5": preload("res://HUD/sprites/plante.png"),
	"mina_semente3": preload("res://HUD/sprites/plante.png"),
	"pantano_semente_4": preload("res://HUD/sprites/plante.png")
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
