extends CanvasLayer

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	print("Pausa alternada via entrada direta!")


func _on_continuar_pressed() -> void:
	toggle_pause()

func _on_opcoes_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/tscn/telaopcoes.tscn")

func _on_menu_principal_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/tscn/menu.tscn")

func _on_sair_jogo_pressed() -> void:
	get_tree().quit()
