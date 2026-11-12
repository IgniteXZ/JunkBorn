extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_botaolivrobotanica_pressed() -> void:
	$Livro.show()
	$"..".hide()

	if not Global.itens_coletados.has("fonte_semente_1"):
		return

	for missao in GerenciadorMissoes.missoes_ativas:
		if missao.id_missao == "verlivro" and not missao.concluida:

			GerenciadorMissoes.completar_missao("verlivro")

			Dialogic.start("descobrindoDiario")
			break


func _on_botaolivronovo_pressed() -> void:
	$Livro2.show()
	$"..".hide()
	
		
