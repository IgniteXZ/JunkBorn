extends Button

@onready var texture_diario: TextureRect = $TextureRect
@export var botanica_normal: Texture2D
@export var botanica_shiny: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if botanica_normal:
		texture_diario.texture = botanica_normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	pass # Replace with function body.


func _on_mouse_entered() -> void:
		if botanica_normal:
			texture_diario.texture = botanica_shiny

func _on_mouse_exited() -> void:
	if botanica_shiny:
			texture_diario.texture = botanica_normal
