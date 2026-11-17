extends VideoStreamPlayer

var _saindo: bool = false

func _ready() -> void:
    # Aguarda a duracao REAL do video, em vez de um timer fixo de 8 segundos.
    loop = false
    finished.connect(_ir_para_inicio)
    if not is_playing():
        play()

func _ir_para_inicio() -> void:
    if _saindo:
        return
    _saindo = true
    get_tree().change_scene_to_file("res://Menu/tscn/menu.tscn")
