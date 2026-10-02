extends Node2D

@onready var Player = $"y-sort/Character"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.cidade_atual = 0
	start_dialog()
		
func start_dialog():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("filomenoChegaVila")
	Player.process_mode = Node.PROCESS_MODE_DISABLED
	
	

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	Player.process_mode = Node.PROCESS_MODE_INHERIT
	
