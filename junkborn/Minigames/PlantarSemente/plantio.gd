extends Area2D

@export var semente: ItemData          # arraste o .tres da SEMENTE (o mesmo usado no item do chão)
@export var planta_scene: PackedScene  # cena que vai aparecer no chão para cada semente
@export var label_interagir: Label     # opcional: aviso "Aperte E" que aparece quando está perto
@export var raio_espalhar: float = 30.0

var perto: bool = false



func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if label_interagir:
		label_interagir.visible = false


func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir") and Global.TerminouOminiGame:
		plantar_sementes()


# Aceita o player pela Area2D dele ou pelo nó pai (ajuste os nomes se for diferente)
func _eh_player(area: Area2D) -> bool:
	if area.name == "Character" or area.name == "Player" or area.is_in_group("Player"):
		return true
	var pai := area.get_parent()
	return pai != null and (pai.name == "Character" or pai.name == "Player" or pai.is_in_group("Player"))


func _on_area_entered(area: Area2D) -> void:
	if _eh_player(area):
		perto = true
		if label_interagir:
			label_interagir.visible = true


func _on_area_exited(area: Area2D) -> void:
	if _eh_player(area):
		perto = false
		if label_interagir:
			label_interagir.visible = false


func _achar_inventario() -> Node:
	var canvas := get_tree().get_first_node_in_group("inventario")
	if canvas == null:
		canvas = get_tree().root.find_child("ui_canvas", true, false)
	return canvas


func plantar_sementes() -> void:
	# Checa tudo ANTES de tirar as sementes do inventário
	if semente == null or planta_scene == null:
		push_error("Defina 'semente' e 'planta_scene' no Inspetor da área de plantio!")
		return

	var canvas := _achar_inventario()
	if canvas == null or not canvas.has_method("remover_itens_por_textura"):
		push_error("Inventário não encontrado ou sem a função 'remover_itens_por_textura'.")
		return

	var qtd: int = canvas.remover_itens_por_textura(semente.textura)
	if qtd <= 0:
		print("Você não tem sementes no inventário!")
		return

	for i in range(qtd):
		var pos := global_position + Vector2(
			randf_range(-raio_espalhar, raio_espalhar),
			randf_range(-raio_espalhar, raio_espalhar)
		)
		_criar_planta(pos)

	print("Plantou ", qtd, " sementes!")


func _criar_planta(pos: Vector2) -> void:
	var nova_planta = planta_scene.instantiate()
	get_parent().add_child(nova_planta)
	nova_planta.global_position = pos
