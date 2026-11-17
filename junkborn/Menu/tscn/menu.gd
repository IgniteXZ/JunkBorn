extends Control

@export var musica: AudioStream
@onready var botao_jogar: Button = $VBoxMenu/Jogar


func _ready() -> void:
	botao_jogar.disabled = true
	get_tree().paused = false

	_limpar_progresso_do_jogo()


	Dialogic.paused = false
	await Dialogic.clear()
	Dialogic.VAR.reset()
	var interface_dialogo: Node = Dialogic.Styles.get_layout_node()
	if is_instance_valid(interface_dialogo):
		interface_dialogo.queue_free()

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

	for missao in GerenciadorMissoes.missoes_ativas:
		if missao != null:
			missao.concluida = false
	GerenciadorMissoes.missoes_ativas.clear()

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

	Global._dialogo_cinco_iniciado = false
	Global._dialogo_cinco_terminado = false
	Global._esperar_visita_plantacao = false
	Global._perto_da_plantacao = false
	Global._dialogo_area_iniciado = false
	Global._dialogo_area_terminado = false
	Global._missao_avo_iniciada = false

	Tutorial.reiniciar()
