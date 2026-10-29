extends Area2D



func _on_area_exited(area: Area2D) -> void:
	$"../../colisoes/StaticBody2D/CollisionShape2D".set_deferred("disabled", false)
