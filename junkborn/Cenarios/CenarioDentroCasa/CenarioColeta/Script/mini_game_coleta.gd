extends Area2D

var comecarMini: bool = false
var interacao = null

func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	comecarMini = true
	interacao = area
	
	GerenciadorMissoes.completar_missao("1")

	print(interacao)


func _on_area_exited(area: Area2D) -> void:
	comecarMini = false
	interacao = null
