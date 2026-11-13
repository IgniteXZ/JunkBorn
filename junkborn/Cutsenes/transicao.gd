extends CanvasLayer

@onready var fade: ColorRect = $Fade
@export var velocidade_fade: float = 0.2 # Velocidade do fade (quanto menor, mais rápido)

func _ready() -> void:
	layer = 100
	# Garante que o ColorRect é preto e começa totalmente invisível (transparente)
	fade.color = Color.BLACK
	fade.modulate.a = 0.0

func fade_out() -> void:
	var tween := create_tween()
	# Faz a tela escurecer (vai de 0.0 até 1.0 de opacidade)
	tween.tween_property(fade, "modulate:a", 1.0, velocidade_fade)
	await tween.finished
	
func fade_in() -> void:
	var tween := create_tween()
	# Faz a tela clarear (vai de 1.0 até 0.0 de opacidade)
	tween.tween_property(fade, "modulate:a", 0.0, velocidade_fade)
	await tween.finished
	
func dormir(pausa: float = 1.5) -> void:
	await fade_out()
	if Dialogic.current_timeline != null:
		Dialogic.Text.hide_textbox(true)
	await get_tree().create_timer(pausa).timeout
	await fade_in()
