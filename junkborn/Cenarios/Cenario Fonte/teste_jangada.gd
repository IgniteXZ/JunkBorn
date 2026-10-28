extends Area2D

@export var aviso: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not jogador_dentro or aberto:
		return

	var c = contar()

	if (c):
		aviso.text = "Aperte E para interagir"
	else:
		aviso.text = "Você precisa de um cano e uma pá para usar a fonte."

	aviso.visible = true


func _on_area_entered(area: Area2D) -> void:
	pass


func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
