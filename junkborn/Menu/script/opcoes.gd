extends Button

@onready var seta = $SetaFoco

var cor_normal = Color("#a6591a")
var cor_foco = Color.WHITE


func _ready() -> void:
	pass



func _on_mouse_entered() -> void:
	grab_focus()


func _on_focus_entered() -> void:
	seta.visible = true
	mudar_cor(cor_foco)


func _on_focus_exited() -> void:
	seta.visible = false
	mudar_cor(cor_normal)


func mudar_cor(cor: Color) -> void:
	add_theme_color_override("font_color", cor)
	add_theme_color_override("font_hover_color", cor)
	add_theme_color_override("font_focus_color", cor)
	add_theme_color_override("font_pressed_color", cor)


	
