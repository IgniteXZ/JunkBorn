extends Area2D

var perto: bool = false
var player: Node2D = null

@onready var labelinteragir = $"../Character/Interagir/LabelInteragir"

func _process(delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		if player.ui_canvas.add_item_inventory($sprite.texture):
			labelinteragir.visible = false
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	perto = true
	player = body
	labelinteragir.visible = true

func _on_body_exited(body: Node2D) -> void:
	perto = false
	player = null
	labelinteragir.visible = false
