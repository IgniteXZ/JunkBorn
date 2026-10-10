extends CanvasLayer

@onready var fade: ColorRect = $Fade

func _ready() -> void:
	layer = 100
	fade.color = Color(0, 0, 0, 1)
	fade.modulate.a = 0.0


func fade_out() -> void:
	fade.modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished


func fade_in() -> void:
	fade.modulate.a = 1.0
	
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	await tween.finished
