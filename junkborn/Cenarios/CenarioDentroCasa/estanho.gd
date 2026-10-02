extends CharacterBody2D

@export var player = CharacterBody2D
@onready var Sprites = $Animate

enum States {DIREITA, ESQUERDA, ABAIXO, CIMA}

var olhar: States = States.ESQUERDA
func _ready() -> void:
	olhar = States.ESQUERDA

func _process(delta: float) -> void:
	if player.position.x > -51.0:
		olhar = States.ESQUERDA
		
	elif  player.position.y > 104.0 and player.position.x < -41.0:
		olhar = States.ABAIXO 
	
	elif player.position.y < 104.0 and player.position.x < -51.0:
		olhar = States.CIMA
		
	Observar()
		
	
func Observar() -> void:
	if olhar == States.ESQUERDA:
		Sprites.play("Andando")
		
	elif olhar == States.CIMA:
		Sprites.play("AndandoCima")
		
	elif olhar == States.ABAIXO:
		Sprites.play("Parado")
	
	
