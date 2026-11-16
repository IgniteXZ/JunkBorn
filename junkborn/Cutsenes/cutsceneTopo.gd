extends VideoStreamPlayer
var passarCena: bool = false
var _saindo: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(35.0).timeout
	_ir_para_inicio()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Confirmar"):
		_ir_para_inicio()
		
func _ir_para_inicio() -> void:
	get_tree().change_scene_to_file("res://Menu/tscn/menu.tscn")
