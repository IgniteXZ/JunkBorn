extends CanvasLayer

@onready var setas_continuar = $panelMain/VBoxContainer/continuar/HBoxContainer
@onready var setas_opcoes = $panelMain/VBoxContainer/opcoes/HBoxContainer2
@onready var setas_menu = $panelMain/VBoxContainer/menuPrincipal/HBoxContainer3
@onready var setas_sair = $panelMain/VBoxContainer/sairJogo/HBoxContainer4

func _ready() -> void:
	visible = false
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
			
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state:
		$panelMain/VBoxContainer/continuar.grab_focus()
	else:
		esconder_todas_setas()
		$Opcoes.hide()
		$Opcoes/ui_controles/Controles.hide()
		$Opcoes/Panel.show()
		$panelMain.show()

func _on_continuar_mouse_entered() -> void: setas_continuar.show()
func _on_continuar_mouse_exited() -> void: setas_continuar.hide()

func _on_opcoes_mouse_entered() -> void: setas_opcoes.show()
func _on_opcoes_mouse_exited() -> void: setas_opcoes.hide()

func _on_menu_principal_mouse_entered() -> void: setas_menu.show()
func _on_menu_principal_mouse_exited() -> void: setas_menu.hide()

func _on_sair_jogo_mouse_entered() -> void: setas_sair.show()
func _on_sair_jogo_mouse_exited() -> void: setas_sair.hide()


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

func _on_sair_jogo_focus_entered() -> void:
	setas_sair.show()

func _on_sair_jogo_focus_exited() -> void:
	setas_sair.hide()
	
func _on_continuar_pressed() -> void:
	toggle_pause()

func _on_opcoes_pressed() -> void:
	$panelMain.hide()
	$Opcoes.show()
	
func _on_opcoes_voltar_pressionado() -> void:
	$Opcoes.hide()
	$panelMain.show()

func _on_menu_principal_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/tscn/menu.tscn")

func _on_sair_jogo_pressed() -> void:
	get_tree().quit()
