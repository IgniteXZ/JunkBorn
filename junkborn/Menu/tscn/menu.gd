extends Control

@export var musica: AudioStream
@onready var botao_jogar: Button = $VBoxMenu/Jogar

# O menu e o ponto unico de reinicio: tanto o Pause quanto o final do jogo
# chegam aqui. Assim, toda nova pessoa na feira comeca do zero.
func _ready() -> void:
	botao_jogar.disabled = true
	get_tree().paused = false

	_limpar_progresso_do_jogo()

	# Clear FULL: limpa timeline, historico e variaveis do Dialogic.
	# O await evita que uma timeline anterior contamine a nova partida.
	Dialogic.paused = false
	await Dialogic.clear()
	Dialogic.VAR.reset()
	var interface_dialogo: Node = Dialogic.Styles.get_layout_node()
	if is_instance_valid(interface_dialogo):
		interface_dialogo.queue_free()

	# Reinicia as interfaces globais, que sobrevivem a mudancas de cena.
	Pause.visible = false
	Pause.animando = false
	ConfirmarSaida.visible = false
	TelaAto.visible = false
	TelaAto.ativo = false
	Transicao.fade.modulate.a = 0.0

	botao_jogar.disabled = false
	botao_jogar.grab_focus()
	AudioManager.tocar_musica(musica)


func _limpar_progresso_do_jogo() -> void:
	# Missoes sao Resources (.tres) com cache no Godot: limpar apenas o
	# array nao basta, pois uma missao concluida continuaria concluida.
	for missao in GerenciadorMissoes.missoes_ativas:
		if missao != null:
			missao.concluida = false
	GerenciadorMissoes.missoes_ativas.clear()

	# Inventario, coletas, diario, mapas e marcadores de acontecimentos.
	Global.itens.clear()
	Global.itens_coletados.clear()
	Global.nomes_itens.clear()
	Global.dados_por_textura.clear()
	Global.paginas_coletadas.clear()
	Global.eventos.clear()
	Global.plantas_plantadas.clear()
	Global.drones_spawnados.clear()

	Global.chamarJangada = false
	Global.cidade_atual = 0
	Global.spawn_destino = ""
	Global.esta_coleta = false
	Global.TerminouOminiGame = false

	# Estado interno do fluxo das cinco sementes e da conversa com o avo.
	Global._dialogo_cinco_iniciado = false
	Global._dialogo_cinco_terminado = false
	Global._esperar_visita_plantacao = false
	Global._perto_da_plantacao = false
	Global._dialogo_area_iniciado = false
	Global._dialogo_area_terminado = false
	Global._missao_avo_iniciada = false

	# Cancela dicas pendentes e torna possivel exibi-las de novo.
	Tutorial.reiniciar()

	# Preservamos as preferencias de audio, que nao sao progresso.
