extends Button

const MenuMissaoTscn = preload("res://HUD/tscn/menumissao.tscn")
var menu_missao_instancia: Node = null
@onready var texture_diario: TextureRect = $TextureRect
@export var diario_normal: Texture2D
@export var diario_shiny: Texture2D



func _ready() -> void:
	if diario_normal:
		texture_diario.texture = diario_normal
	# Tenta instanciar o recurso
	menu_missao_instancia = MenuMissaoTscn.instantiate()
	add_child(menu_missao_instancia)
	
	menu_missao_instancia.visible = false
	
	


func _on_pressed() -> void:
	print("67")
	menu_missao_instancia.show()


func _on_mouse_entered() -> void:
		if diario_normal:
			texture_diario.texture = diario_shiny
	


func _on_mouse_exited() -> void:
	if diario_shiny:
			texture_diario.texture = diario_normal
