extends Button
#@export var MenuFechaMissaoTscn: PackedScene
#var MenuFechaMissaoTscn = load("res://HUD/tscn/menumissao.tscn")
#var menu_fecha_missao_instancia: Node = null

@export var menuMissao: Node

func _ready() -> void:
	# Tenta instanciar o recurso
	#menu_fecha_missao_instancia = MenuFechaMissaoTscn.instantiate()

	#add_child(menu_fecha_missao_instancia)
	pass


func _on_pressed() -> void:
	menuMissao.hide()
	#print("67")
	#menu_fecha_missao_instancia.hide()
