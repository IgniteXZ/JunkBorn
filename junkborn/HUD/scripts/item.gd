extends Area2D

var perto: bool = false
var player: Area2D = null

@export var labelinteragir: Label

@export var canvas: CanvasLayer


func _process(delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		if canvas.add_item_inventory($sprite.texture):
			labelinteragir.visible = false
			queue_free()
			


func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area
	labelinteragir.visible = true


func _on_area_exited(area: Area2D) -> void:
	perto = false
	player = null
	labelinteragir.visible = false
