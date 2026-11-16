extends Control

signal voltar_controles_pressionado

# As teclas do menu usam o mesmo estilo de PanelContainer do tutorial.
# Os nomes sao lidos do InputMap, evitando imagens provisorias ou letras erradas.
const TECLA_VISUAL = preload("res://Menu/script/tecla_visual.gd")

@onready var movimento: VBoxContainer = $Panel/ScrollContainer/VBoxContainer/WasdSprite
@onready var interagir: HBoxContainer = $Panel/ScrollContainer/VBoxContainer/InteragirSprite
@onready var inventario: HBoxContainer = $Panel/ScrollContainer/VBoxContainer/InventarioSprite
@onready var mapa: HBoxContainer = $Panel/ScrollContainer/VBoxContainer/MapaSprite
@onready var pausar: HBoxContainer = $Panel/ScrollContainer/VBoxContainer/PausarSprite

func _ready() -> void:
    _montar_movimento()
    _adicionar_teclas(interagir, [_nome_tecla("Interagir")])
    _adicionar_teclas(inventario, [_nome_tecla("inventory")])
    _adicionar_teclas(mapa, [_nome_tecla("Mapa")])
    _adicionar_teclas(pausar, [_nome_tecla("ui_cancel")])

func _montar_movimento() -> void:
    movimento.add_theme_constant_override("separation", 8)
    _adicionar_fileira_movimento([_nome_tecla("move_up")])
    _adicionar_fileira_movimento([
        _nome_tecla("move_left"),
        _nome_tecla("move_down"),
        _nome_tecla("move_right")
    ])

func _adicionar_fileira_movimento(teclas: Array) -> void:
    var fileira := HBoxContainer.new()
    fileira.alignment = BoxContainer.ALIGNMENT_CENTER
    fileira.mouse_filter = Control.MOUSE_FILTER_IGNORE
    movimento.add_child(fileira)
    _adicionar_teclas(fileira, teclas)

func _adicionar_teclas(container: HBoxContainer, teclas: Array) -> void:
    container.alignment = BoxContainer.ALIGNMENT_CENTER
    container.add_theme_constant_override("separation", 8)
    for nome in teclas:
        var visual = TECLA_VISUAL.new()
        visual.texto = str(nome)
        container.add_child(visual)

func _nome_tecla(acao: String) -> String:
    for ev in InputMap.action_get_events(acao):
        var tecla_ev := ev as InputEventKey
        if tecla_ev == null:
            continue
        var codigo: Key = tecla_ev.physical_keycode if tecla_ev.physical_keycode != 0 else tecla_ev.keycode
        if codigo == KEY_ESCAPE:
            return "ESC"
        if codigo == KEY_TAB:
            return "TAB"
        return OS.get_keycode_string(codigo).to_upper()
    return acao.to_upper()
