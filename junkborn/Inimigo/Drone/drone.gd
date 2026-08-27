extends CharacterBody2D

var OndeEuvou: Vector2
var Perseguicao: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if Perseguicao:
		velocity = position.direction_to(OndeEuvou) * 100
	move_and_slide()	




func _on_detectar_mandar_aura(posicaoGlobal: Vector2) -> void:
	print(posicaoGlobal)
	OndeEuvou = posicaoGlobal
	Perseguicao = true


func _on_detectar_tirar_aura(Tirar: bool) -> void:
	Perseguicao = false
