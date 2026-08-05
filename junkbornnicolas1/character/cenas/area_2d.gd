extends Area2D

var sim: bool = false
@onready var labelinteragir = $"../Character/Interagir/LabelInteragir"


func _process(delta: float) -> void:
	if Dialogic.current_timeline != null:
		return

	if  Input.is_action_just_pressed("Interagir") and sim:
		get_tree().paused = true
		Dialogic.start('Teste')
		get_viewport().set_input_as_handled()
		
		
	get_tree().paused = false
		

func _interact(area: Area2D) -> void:
	sim = true
	labelinteragir.visible = true

func _on_interagir_area_exited(area: Area2D) -> void:
	sim = false
	labelinteragir.visible = false
