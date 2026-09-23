extends Area2D
var perto: bool = false
var player: Area2D = null


@export var labelInteragir: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
			print("gonnei")
			get_tree().change_scene_to_file("res://Cenarios/CenarioDentroCasa/SalaCasa.tscn")


func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area
	labelInteragir.visible = true


func _on_area_exited(area: Area2D) -> void:
	perto = false
	player = null
	labelInteragir.visible = false
