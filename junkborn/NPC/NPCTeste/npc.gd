class_name NPCBase
extends CharacterBody2D

@export var NPCdados: NPCResource
@export var Sprite: Sprite2D
var Nome: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MudarSprite()
	Nome = NPCdados.nomeNPC
	
func MudarSprite():
	Sprite.texture = NPCdados.Sprite
	
func ChamarDialogo(Timeline: String) -> void:
	Dialogic.start(Timeline)
