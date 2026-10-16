extends Control

signal voltar_pressionado
var estilo_check: StyleBox
var estilo_janela: StyleBox

@export var ButtonSong: CheckButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	estilo_check = $Panel/VBoxOpcoes/HBoxMusica/AreaCheckMusica/CheckMusica.get_theme_stylebox("focus")
	estilo_janela = $Panel/VBoxOpcoes/HBoxTela/OpcaoTela.get_theme_stylebox("focus")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ButtonSong.button_pressed:
		Global.DesligarMusica = false
	else:
		Global.DesligarMusica = true
		
func animar_painel(painel: Control, abrindo: bool) -> void:
	var posicao = painel.position
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	if abrindo:
		painel.modulate.a = 0.0
		painel.position = posicao + Vector2(0, 8)
		tween.tween_property(painel, "modulate:a", 1.0, 0.25)
		tween.tween_property(painel, "position", posicao, 0.25)
	else:
		tween.tween_property(painel, "modulate:a", 0.0, 0.2)
		tween.tween_property(painel, "position", posicao + Vector2(0, 8), 0.2)

	await tween.finished
	
func _on_ver_controles_pressed() -> void:
	await animar_painel($Panel, false)
	$Panel.hide()
	$Controles.show()
	await animar_painel($Controles, true)


func _on_controles_voltar_controles_pressionado() -> void:
	await animar_painel($Controles, false)
	$Controles.hide()
	$Panel.show()
	await animar_painel($Panel, true)
	
func _on_ver_controles_focus_entered() -> void:
	$Panel/VBoxOpcoes/HBoxControles/VerControles/SetaFoco.show()

func _on_ver_controles_focus_exited() -> void:
	$Panel/VBoxOpcoes/HBoxControles/VerControles/SetaFoco.hide()

func _on_voltar_opcoes_focus_entered() -> void:
	$Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes/SetaFoco.show()

func _on_voltar_opcoes_focus_exited() -> void:
	$Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes/SetaFoco.hide()
	

func _on_ver_controles_mouse_entered() -> void:
	var botao = $Panel/VBoxOpcoes/HBoxControles/VerControles
	botao.grab_focus()
	$Panel/VBoxOpcoes/HBoxControles/VerControles/SetaFoco.show()

func _on_ver_controles_mouse_exited() -> void:
	if not $Panel/VBoxOpcoes/HBoxControles/VerControles.has_focus():
		$Panel/VBoxOpcoes/HBoxControles/VerControles/SetaFoco.hide()

func _on_voltar_opcoes_mouse_entered() -> void:
	var botao = $Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes
	botao.grab_focus()
	$Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes/SetaFoco.show()
	
func _on_voltar_opcoes_mouse_exited() -> void:
	if not $Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes.has_focus():
		$Panel/VBoxOpcoes/HBoxVoltar/VoltarOpcoes/SetaFoco.hide()
		

func _on_check_musica_mouse_entered() -> void:
	var check = $Panel/VBoxOpcoes/HBoxMusica/AreaCheckMusica/CheckMusica
	check.add_theme_stylebox_override("focus", estilo_check)
	check.grab_focus()

func _on_check_som_mouse_entered() -> void:
	var check = $Panel/VBoxOpcoes/HBoxSom/AreaCheckSom/CheckSom
	check.add_theme_stylebox_override("focus", estilo_check)
	check.grab_focus()

func _on_opcao_tela_mouse_entered() -> void:
	var botao = $Panel/VBoxOpcoes/HBoxTela/OpcaoTela
	botao.grab_focus()
