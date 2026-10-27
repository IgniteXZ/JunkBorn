extends Node2D
@export var mandacaru: CharacterBody2D
@export var npc: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.cidade_atual = 3
	if Dialogic.VAR.deserto_liberado == true:
		mandacaru.visible = true
		mandacaru.position = Vector2(-673,379)
		
		npc.visible = true
		npc.position = Vector2(-566, 514)
		print("teleportou")
