extends CanvasLayer

@onready var fade: ColorRect = $Fade

func _ready() -> void:
	layer = 100
	if fade.material is ShaderMaterial:
		fade.material.set_shader_parameter("luminance_cutoff", 0.0) # <--- "progress" minúsculo

func fade_out() -> void:
	var material = fade.material as ShaderMaterial
	if not material: return
	
	var tween := create_tween()
	tween.tween_method(
		func(val): material.set_shader_parameter("luminance_cutoff", val), # <--- "progress" minúsculo
		0.0, 1.0, 0.5
	)
	await tween.finished
	
func fade_in() -> void:
	var material = fade.material as ShaderMaterial
	if not material: return
	
	var tween := create_tween()
	tween.tween_method(
		func(val): material.set_shader_parameter("luminance_cutoff", val), # <--- "progress" minúsculo
		1.0, 0.0, 0.5
	)
	await tween.finished
