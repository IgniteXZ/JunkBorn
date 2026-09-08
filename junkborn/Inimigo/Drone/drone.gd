extends RigidBody2D

var OndeEuvou: Vector2
var Perseguicao: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	
	if Perseguicao:
		var direction = global_position.direction_to(OndeEuvou)
		apply_central_impulse(direction * 5)
		look_at(OndeEuvou)
		sleeping = false
		print(linear_velocity.length())
		
	elif linear_velocity.length() < 2:
		sleeping = true
		
		
	
	




func _on_detectar_mandar_aura(posicaoGlobal: Vector2) -> void:
	print(posicaoGlobal)
	OndeEuvou = posicaoGlobal
	Perseguicao = true


func _on_detectar_tirar_aura(Tirar: bool) -> void:
	Perseguicao = false
