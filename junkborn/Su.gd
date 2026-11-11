extends Node2D

var drone = preload("res://Inimigo/Drone/drone.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 2:
		var a = drone.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
