extends RigidBody2D

var OndeEuvou: Vector2
var Perseguicao: bool = false

var ImpulsoMaster: float = 5
var impulso: bool = false

@export var Tempo: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	IniciarTempo()


func _physics_process(delta: float) -> void:
	
	if Perseguicao and linear_velocity.length() < 255.5 and not impulso:
		var direction = global_position.direction_to(OndeEuvou)
		apply_central_impulse(direction * ImpulsoMaster)
		sleeping = false
		Tempo.paused = false
		
	if Perseguicao and impulso:
		await  get_tree().create_timer(0.4).timeout
		var direction = global_position.direction_to(OndeEuvou)
		apply_central_impulse(direction * 25)
		sleeping = false
		Tempo.paused = false
		impulso = false
		
	
	if Perseguicao:
		look_at(OndeEuvou)
		
	
		
	elif linear_velocity.length() < 2:
		#Tempo.stop()
		Tempo.paused = true
		sleeping = true


func IniciarTempo():
	Tempo.start()

#SInais
func _on_detectar_mandar_aura(posicaoGlobal: Vector2) -> void:
	OndeEuvou = posicaoGlobal
	Perseguicao = true


func _on_detectar_tirar_aura(Tirar: bool) -> void:
	Perseguicao = false


func _on_timer_timeout() -> void:
	impulso = true
	
