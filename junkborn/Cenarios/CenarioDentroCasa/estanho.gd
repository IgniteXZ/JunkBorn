extends CharacterBody2D

@export var player = CharacterBody2D
@onready var Sprites = $Animate

enum States {DIREITA, ESQUERDA, ABAIXO, CIMA}

var olhar: States = States.ESQUERDA
func _ready() -> void:
	olhar = States.ESQUERDA

func _process(_delta: float) -> void:
	_processarIdle()


	
func _processarIdle() -> void:
		
	if  player.position.y > 104.0 and player.position.x < -41.0:
		olhar = States.ABAIXO 
	
	elif player.position.y < 104.0 and player.position.x < -51.0:
		olhar = States.CIMA
	elif player.position.x > -51.0:
		olhar = States.ESQUERDA
		
	Observar()
		
	
func Observar() -> void:
	if olhar == States.ESQUERDA:
		Sprites.play("Andando")
		
	elif olhar == States.CIMA:
		Sprites.play("AndandoCima")
		
	elif olhar == States.ABAIXO:
		Sprites.play("Parado")
	
	
