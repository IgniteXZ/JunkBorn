extends VideoStreamPlayer
var passarCena: bool = false
var _saindo: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(8.0).timeout
	_ir_para_vila()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Confirmar"):
		_ir_para_vila()
		
func _ir_para_vila() -> void:
	if _saindo:
		return
	_saindo = true
	TelaAto.mostrar("PRÓLOGO", "res://Cenarios/CenarioVila/characterP.tscn" )
