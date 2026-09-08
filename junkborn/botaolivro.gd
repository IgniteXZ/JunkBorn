extends Button

const MenuMissaoTscn = preload("res://HUD/tscn/menumissao.tscn")
var menu_missao_instancia: Node = null

func _ready() -> void:
	# Tenta instanciar o recurso
	menu_missao_instancia = MenuMissaoTscn.instantiate()
	add_child(menu_missao_instancia)
	
	menu_missao_instancia.visible = false

func _on_pressed() -> void:
	print("67")
	menu_missao_instancia.show()
