extends Area2D

@onready var _jogador: Node = get_parent()
var _labels: Array = []

func _ready() -> void:
	_iniciar.call_deferred()

func _iniciar() -> void:
	_labels = _jogador.find_children("LabelInteragir", "Label", true, false)
	for l in _labels:
		l.visible = false

func _process(_delta: float) -> void:
	if _labels.is_empty():
		return
	var encostando := false
	for area in get_overlapping_areas():
		if area.get_parent() != _jogador:
			encostando = true
			break
	if not encostando:
		for l in _labels:
			l.visible = false
		return
	var visiveis := _labels.filter(func(l): return l.visible)
	if visiveis.size() > 1:
		for l in visiveis:
			if l.get_parent() != self:
				l.visible = false
