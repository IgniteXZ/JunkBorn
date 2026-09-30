extends CharacterBody2D

@export var player = CharacterBody2D
@onready var Sprites = $Animate

enum States {DIREITA, ESQUERDA, ABAIXO, CIMA}

var olhar: States = States.ESQUERDA
func _ready() -> void:
	olhar = States.ESQUERDA

func _process(_delta: float) -> void:
	look_at(player.position)
	if player.position.x > -51.0:
		olhar = States.ESQUERDA
	elif  player.position.y < 104.0 and player.position.x < -51.0:
		olhar = States.ABAIXO 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match olhar:
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
		
	elif  player.position.y < 104.0 and player.position.x < -51.0:
		olhar = States.ABAIXO 
	
	elif player.position.y > 104.0 and player.position.x < -51.0:
		olhar = States.CIMA
		
	
func Observar() -> void:
	if olhar == States.ESQUERDA:
		Sprites.play("Andando")
		
	elif olhar == States.ABAIXO:
		Sprites.play("AndandoCima")
		
	#elif olhar == States.CIMA:
		#Sprites.play("Andando")
	
	
