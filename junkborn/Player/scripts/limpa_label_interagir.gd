extends Area2D

@onready var _jogador: Node = get_parent()

func _process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area.get_parent() != _jogador:
			return
	for label in _jogador.find_children("LabelInteragir", "Label", true, false):
		label.visible = false
