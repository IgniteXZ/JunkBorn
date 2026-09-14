extends Button



func _ready() -> void:
	pass



func _on_pressed() -> void:
	owner.fechar_coleta.emit()
