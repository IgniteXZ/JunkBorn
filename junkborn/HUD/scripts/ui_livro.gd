extends CanvasLayer

# Evita iniciar a timeline enquanto o diário ainda estiver aberto.
# A missão e o diálogo são concluídos/disparados apenas ao clicar em Sair.
var _dialogo_diario_pendente: bool = false


func _ready() -> void:
	var botao_fechar := $Livro/BookArea/Fechar as Button
	# O botão original esconde o Livro; esta chamada diferida ocorre depois.
	botao_fechar.pressed.connect(_ao_fechar_diario, CONNECT_DEFERRED)


func _on_botaolivrobotanica_pressed() -> void:
	var diario := $Livro
	var primeira_leitura: bool = (
		Global.itens_coletados.has("fonte_semente_1")
		and not Global.eventos.get("diario_fonte_lido", false)
	)

	_dialogo_diario_pendente = false
	if primeira_leitura:
		for missao in GerenciadorMissoes.missoes_ativas:
			if missao.id_missao == "verlivro" and not missao.concluida:
				_dialogo_diario_pendente = true
				# Páginas 3 e 4, que acabaram de ser desbloqueadas.
				diario.indice_esquerda = 2
				break

	diario.show()
	diario.atualizar_paginas()
	$"..".hide()


func _ao_fechar_diario() -> void:
	# Não aciona o diálogo em outros fechamentos de interface.
	if not _dialogo_diario_pendente or $Livro.visible:
		return
	_dialogo_diario_pendente = false
	if Global.eventos.get("diario_fonte_lido", false):
		return
	Global.eventos["diario_fonte_lido"] = true
	GerenciadorMissoes.completar_missao("verlivro")

	# A interface precisa estar fechada antes de iniciar o Dialogic.
	await get_tree().process_frame
	if Dialogic.current_timeline != null:
		await Dialogic.timeline_ended
	Dialogic.start("descobrindoDiario")


func _on_botaolivronovo_pressed() -> void:
	$Livro2.show()
	$"..".hide()
