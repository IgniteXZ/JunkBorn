extends Node2D

@onready var buraco_final: TileMapLayer = $"y-sort/buracofinal"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.cidade_atual = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	buraco_final.visible = Global.eventos.get("tela_ato_exibida:ATO 2: O Agricultor", false)
