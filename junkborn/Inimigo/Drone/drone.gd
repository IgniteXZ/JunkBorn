extends RigidBody2D

var OndeEuvou: Vector2
var Perseguicao: bool = false

var ImpulsoMaster: float = 5

@export var Tempo: Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	if Perseguicao and linear_velocity.length() < 255.5:
		var direction = global_position.direction_to(OndeEuvou)
		apply_central_impulse(direction * ImpulsoMaster)
		sleeping = false
		Tempo.paused = false
	
	if Perseguicao:
		look_at(OndeEuvou)
		
	elif linear_velocity.length() < 2:
		Tempo.stop()
		sleeping = true
	

func _on_detectar_mandar_aura(posicaoGlobal: Vector2) -> void:
	OndeEuvou = posicaoGlobal
	Perseguicao = true


func _on_detectar_tirar_aura(Tirar: bool) -> void:
	Perseguicao = false


func _on_timer_timeout() -> void:
	ImpulsoMaster = 50
	print("Sigma")
