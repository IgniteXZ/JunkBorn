extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_opcoes_pressed() -> void:
	var painel = $Opcoes/Panel
	$Opcoes.show()

	painel.modulate.a = 0.0
	painel.position += Vector2(0, 8)

	var posicao_final = painel.position - Vector2(0, 8)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(painel, "modulate:a", 1.0, 0.25)
	tween.tween_property(painel, "position", posicao_final, 0.25)

	await tween.finished
	$Opcoes/Panel/VBoxOpcoes/HBoxSom/AreaCheckSom/CheckSom.grab_focus()


func _on_opcoes_voltar_pressionado() -> void:
	var painel = $Opcoes/Panel
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(painel, "modulate:a", 0.0, 0.2)
	tween.tween_property(painel, "position", painel.position + Vector2(0, 8), 0.2)

	await tween.finished
	$Opcoes.hide()
	painel.modulate.a = 1.0
	painel.position -= Vector2(0, 8)
	get_parent().get_node("VBoxMenu/Opcoes").grab_focus()
