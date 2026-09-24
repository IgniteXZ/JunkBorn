extends CharacterBody2D

enum Estado {IDLE, WALK}
@export var WayPoint: Array[Vector2] = []
@export var velocidade: float = 60.0
@export var tempoParadex: float = 2.0

@export var player = CharacterBody2D

var estado: Estado = Estado.IDLE
var indiceWaypoint: int = 0
var tempoParado: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

func _process(_delta: float) -> void:
	look_at(player.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match estado:
		Estado.IDLE:
			_processarIdle(delta)
		Estado.WALK:
			_processarWalk()
	move_and_slide()
	
func _processarIdle(delta: float) -> void:
	velocity = Vector2.ZERO
	tempoParado -= delta
	if tempoParado <= 0.0 and WayPoint.size() > 1:
		estado = Estado.WALK
		
func _processarWalk() -> void:
	var alvo: Vector2 = WayPoint[indiceWaypoint]
	if global_position.distance_to(alvo) < 4.0:
		indiceWaypoint = (indiceWaypoint + 1) %	 WayPoint.size()
		tempoParado = tempoParadex
		estado = Estado.IDLE
		return
	var direcao:  Vector2 = global_position.direction_to(alvo)
	velocity = velocity.move_toward(direcao * velocidade, velocidade * 8.0 * get_physics_process_delta_time())
	#mudar direcao de sprite aqui
