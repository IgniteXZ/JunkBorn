extends PanelContainer

# Componente reutilizavel: visual de tecla identico ao usado no tutorial.
@export var texto: String = "E"

const FONTE: Font = preload("res://Fonte/PressStart2P.ttf")
const TAM_FONTE: int = 16

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = Vector2(44, 44)

    var estilo := StyleBoxFlat.new()
    estilo.bg_color = Color("#f0f0f0")
    estilo.border_color = Color("#6b6b6b")
    estilo.set_border_width_all(2)
    estilo.border_width_bottom = 6
    estilo.content_margin_left = 10
    estilo.content_margin_right = 10
    estilo.content_margin_top = 6
    estilo.content_margin_bottom = 12
    add_theme_stylebox_override("panel", estilo)

    var rotulo := Label.new()
    rotulo.text = texto
    rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rotulo.add_theme_font_override("font", FONTE)
    rotulo.add_theme_font_size_override("font_size", TAM_FONTE)
    rotulo.add_theme_color_override("font_color", Color("#202020"))
    add_child(rotulo)
