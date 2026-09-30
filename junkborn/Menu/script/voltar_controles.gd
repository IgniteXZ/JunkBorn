extends Button


func _on_pressed() -> void:
	owner.voltar_controles_pressionado.emit()
