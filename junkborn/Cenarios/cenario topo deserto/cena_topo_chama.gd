extends Area2D

var _iniciando: bool = false

func _ready() -> void:
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)

func _missao_final_ativa() -> bool:
    for missao in GerenciadorMissoes.missoes_ativas:
        if missao.id_missao == "missaofinal" and not missao.concluida:
            return true
    return false

func _on_area_entered(area: Area2D) -> void:
    # Somente a area de interacao do jogador pode iniciar a cutscene.
    if _iniciando or area.name != "Interagir" or not area.get_parent().is_in_group("player"):
        return
    if not _missao_final_ativa():
        return
    _iniciando = true
    get_tree().call_deferred("change_scene_to_file", "res://Cutsenes/CutsceneTopo.tscn")
