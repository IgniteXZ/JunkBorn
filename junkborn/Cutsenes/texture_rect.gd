extends TextureRect
var passarCena: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(5.0).timeout
	passarCena = true
	if passarCena:
		get_tree().change_scene_to_file("res://Cenarios/CenarioVila/characterP.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Confirmar"):
		print("DEDEI o JJ")
		get_tree().change_scene_to_file("res://Cenarios/CenarioVila/characterP.tscn")
