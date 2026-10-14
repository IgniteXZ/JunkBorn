extends Control

signal voltar_pressionado

@export var ButtonSong: CheckButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
