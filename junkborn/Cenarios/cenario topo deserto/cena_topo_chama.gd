extends Area2D

# O topo pode ser ativado tanto pelo corpo fisico do jogador quanto
# pela Area2D Interagir. A versao anterior dependia somente de Interagir.
var _iniciando: bool = false

func _ready() -> void:
    monitoring = true
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
    _checar_jogador_ja_dentro.call_deferred()

func _missao_final_ativa() -> bool:
    for missao in GerenciadorMissoes.missoes_ativas:
        if is_instance_valid(missao) and missao.id_missao == "missaofinal" and not missao.concluida:
            return true
    return false

func _tentar_iniciar() -> void:
    if _iniciando:
        return
    if not _missao_final_ativa():
        push_warning("Topo: Filomeno chegou ao gatilho, mas a missao 'missaofinal' nao esta ativa.")
        return

    _iniciando = true
    print("Topo: missao final ativa; iniciando cutscene.")
    get_tree().call_deferred("change_scene_to_file", "res://Cutsenes/CutsceneTopo.tscn")

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _tentar_iniciar()

func _on_area_entered(area: Area2D) -> void:
    if area.name == "Interagir" and area.get_parent() != null and area.get_parent().is_in_group("player"):
        _tentar_iniciar()

func _checar_jogador_ja_dentro() -> void:
    # Caso o personagem inicie ou apareca dentro do gatilho.
    if not is_inside_tree():
        return
    await get_tree().physics_frame
    if not is_inside_tree():
        return
    for body in get_overlapping_bodies():
        if body.is_in_group("player"):
            _tentar_iniciar()
            return
    for area in get_overlapping_areas():
        if area.name == "Interagir" and area.get_parent() != null and area.get_parent().is_in_group("player"):
            _tentar_iniciar()
            return
