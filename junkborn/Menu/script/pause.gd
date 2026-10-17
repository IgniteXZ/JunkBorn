
extends CanvasLayer

@onready var setas_continuar = $panelMain/VBoxContainer/continuar/HBoxContainer
@onready var setas_opcoes = $panelMain/VBoxContainer/opcoes/HBoxContainer2
@onready var setas_menu = $panelMain/VBoxContainer/menuPrincipal/HBoxContainer3
@onready var setas_sair = $panelMain/VBoxContainer/sairJogo/HBoxContainer4

var animando := false
var posicao_original: Vector2
var posicao_opcoes: Vector2

func _ready() -> void:
	visible = false
	posicao_original = $panelMain.position
	posicao_opcoes = $Opcoes/Panel.position
	esconder_todas_setas()

func esconder_todas_setas() -> void:
	setas_continuar.hide()
	setas_opcoes.hide()
	setas_menu.hide()
	setas_sair.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.is_in_group("no_pause"):
			return

		if get_tree().get_nodes_in_group("minigame_aberto").size() > 0:
			return

		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if animando:
		return

	var new_pause_state = !get_tree().paused

	if new_pause_state:
		get_tree().paused = true
		visible = true
		$Opcoes.hide()
		$panelMain.show()

		var painel = $panelMain
		painel.modulate.a = 0.0
		painel.position = posicao_original + Vector2(0, 8)

		$panelMain/VBoxContainer/continuar.grab_focus()

		animando = true
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_parallel(true)
		tween.tween_property(painel, "modulate:a", 1.0, 0.25)
		tween.tween_property(painel, "position", posicao_original, 0.25)
		await tween.finished
		animando = false
	else:
		animando = true
		esconder_todas_setas()

		var painel = $panelMain
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_parallel(true)
		tween.tween_property(painel, "modulate:a", 0.0, 0.2)
		tween.tween_property(painel, "position", posicao_original + Vector2(0, 8), 0.2)
		await tween.finished

		$Opcoes.hide()
		$Opcoes/Controles.hide()
		$Opcoes/Panel.show()
		$panelMain.show()

		painel.modulate.a = 1.0
		painel.position = posicao_original
		visible = false
		get_tree().paused = false
		animando = false

func _on_continuar_mouse_entered() -> void:
	setas_continuar.show()

func _on_continuar_mouse_exited() -> void:
	setas_continuar.hide()

func _on_opcoes_mouse_entered() -> void:
	setas_opcoes.show()

func _on_opcoes_mouse_exited() -> void:
	setas_opcoes.hide()

func _on_menu_principal_mouse_entered() -> void:
	setas_menu.show()

func _on_menu_principal_mouse_exited() -> void:
	setas_menu.hide()

func _on_sair_jogo_mouse_entered() -> void:
	setas_sair.show()

func _on_sair_jogo_mouse_exited() -> void:
	setas_sair.hide()

func _on_continuar_focus_entered() -> void:
	setas_continuar.show()

func _on_continuar_focus_exited() -> void:
	setas_continuar.hide()

func _on_opcoes_focus_entered() -> void:
	setas_opcoes.show()

func _on_opcoes_focus_exited() -> void:
	setas_opcoes.hide()

func _on_menu_principal_focus_entered() -> void:
	setas_menu.show()

func _on_menu_principal_focus_exited() -> void:
	setas_menu.hide()

func _on_sair_focus_entered() -> void:
	setas_sair.show()

func _on_sair_focus_exited() -> void:
	setas_sair.hide()

func _on_continuar_pressed() -> void:
	toggle_pause()

func _on_opcoes_pressed() -> void:
	$panelMain.hide()
	$Opcoes.show()

	var painel = $Opcoes/Panel
	painel.position = posicao_opcoes + Vector2(0, 8)
	painel.modulate.a = 0.0

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(painel, "modulate:a", 1.0, 0.25)
	tween.tween_property(painel, "position", posicao_opcoes, 0.25)

	await tween.finished
	$Opcoes/Panel/VBoxOpcoes/HBoxSom/AreaCheckSom/CheckSom.grab_focus()

func _on_opcoes_voltar_pressionado() -> void:
	var painel = $panelMain
	painel.show()
	painel.modulate.a = 0.0
	painel.position = posicao_original + Vector2(0, 8)

	$Opcoes.hide()

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(painel, "modulate:a", 1.0, 0.25)
	tween.tween_property(painel, "position", posicao_original, 0.25)

	await tween.finished
	$panelMain/VBoxContainer/opcoes.grab_focus()

func _on_menu_principal_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/tscn/menu.tscn")

func _on_sair_jogo_pressed() -> void:
	ConfirmarSaida.abrir()
