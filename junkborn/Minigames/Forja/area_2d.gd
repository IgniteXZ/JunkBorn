extends Area2D


var perto: bool = false

var player: Area2D = null

var label_interagir_do_player: Label = null

var canvass: CanvasLayer = null


const TELA_PRENSA_SCENE = preload("res://Minigames/Forja/telaPrensa.tscn")

var tela_prensa_instanciada: Control = null


func _ready() -> void:

	var root = get_tree().root

	var canvas_no_jogo = _buscar_canvas_na_arvore(root)

	if canvas_no_jogo:

		canvass = canvas_no_jogo


func _buscar_canvas_na_arvore(no_atual: Node) -> CanvasLayer:

	if no_atual is CanvasLayer:

		if no_atual.has_method("add_item_inventory") or no_atual.name.to_lower().contains("canvas"):

			return no_atual

	for filho in no_atual.get_children():

		var resultado = _buscar_canvas_na_arvore(filho)

		if resultado:

			return resultado

	return null


func _process(delta: float) -> void:

	if perto and Input.is_action_just_pressed("Interagir"):

		if not canvass and player:

			if "canvass" in player: canvass = player.canvass

			elif "canva" in player: canvass = player.canva

			

		if tela_prensa_instanciada == null:

			_abrir_prensa()

		else:

			_fechar_prensa()


func _abrir_prensa():

	if canvass:

		tela_prensa_instanciada = TELA_PRENSA_SCENE.instantiate()

		canvass.add_child(tela_prensa_instanciada)

		canvass.move_child(tela_prensa_instanciada, 0)

		

		if tela_prensa_instanciada.has_method("_on_character_passar_canvas"):

			tela_prensa_instanciada._on_character_passar_canvas(canvass)

			

		if label_interagir_do_player: 

			label_interagir_do_player.visible = false

	else:

		print("ERRO: A prensa ainda não recebeu o Canvas do Player!")


func _fechar_prensa():

	if tela_prensa_instanciada and is_instance_valid(tela_prensa_instanciada):

		# Chama a rotina da Prensa de devolver itens ao inventário antes de fechar

		if tela_prensa_instanciada.has_method("fechar_tela"):

			tela_prensa_instanciada.fechar_tela()

		else:

			tela_prensa_instanciada.queue_free()

		

	tela_prensa_instanciada = null

	if perto and label_interagir_do_player:

		label_interagir_do_player.visible = true


func _on_area_entered(area: Area2D) -> void:

	perto = true

	player = area


	label_interagir_do_player = area.get_node_or_null("LabelInteragir")

	if not label_interagir_do_player:

		label_interagir_do_player = area.get_node_or_null("Interagir/LabelInteragir")

		

	if label_interagir_do_player and tela_prensa_instanciada == null:

		label_interagir_do_player.visible = true


func _on_area_exited(area: Area2D) -> void:

	perto = false

	player = null

	if label_interagir_do_player:

		label_interagir_do_player.visible = false

	_fechar_prensa()


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:

	canvass = canvas 
