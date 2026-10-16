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
		

func _on_ver_controles_pressed() -> void:
	$Panel.hide()
	$Controles.show()

func _on_controles_voltar_controles_pressionado() -> void:
	$Controles.hide()
	$Panel.show()
	
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
