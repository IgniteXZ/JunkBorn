extends Area2D


var perto: bool = false

var player: Area2D = null

var label_interagir_do_player: Label = null

var canvass: CanvasLayer = null


const TELA_FORJA_SCENE = preload("res://Minigames/Forja/telaForja.tscn")

var tela_forja_instanciada: Control = null


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

			

		if tela_forja_instanciada == null:

			_abrir_forja()

		else:

			_fechar_forja()


func _abrir_forja():

	if canvass:

		tela_forja_instanciada = TELA_FORJA_SCENE.instantiate()

		canvass.add_child(tela_forja_instanciada)

		

	

		canvass.move_child(tela_forja_instanciada, 0)

		

		if tela_forja_instanciada.has_method("_on_character_passar_canvas"):

			tela_forja_instanciada._on_character_passar_canvas(canvass)

			

		if label_interagir_do_player: 

			label_interagir_do_player.visible = false

	else:

		print("ERRO: A bancada ainda não recebeu o Canvas do Player!")



func _fechar_forja():

	if tela_forja_instanciada and is_instance_valid(tela_forja_instanciada):

		if "linhas_carregadas" in tela_forja_instanciada:

			for linha in tela_forja_instanciada.linhas_carregadas:

				if "slots_da_linha" in linha:

					for slot in linha.slots_da_linha:

						if slot.has_method("_devolver_itens_ao_inventario") and slot.quantidade_acumulada > 0:

							slot._devolver_itens_ao_inventario()

		tela_forja_instanciada.queue_free()

		

	tela_forja_instanciada = null

	if perto and label_interagir_do_player:

		label_interagir_do_player.visible = true


func _on_area_entered(area: Area2D) -> void:

	perto = true

	player = area

	


	label_interagir_do_player = area.get_node_or_null("LabelInteragir")

	if not label_interagir_do_player:

		

		label_interagir_do_player = area.get_node_or_null("Interagir/LabelInteragir")

		

	if label_interagir_do_player and tela_forja_instanciada == null:

		label_interagir_do_player.visible = true


func _on_area_exited(area: Area2D) -> void:

	perto = false

	player = null

	if label_interagir_do_player:

		label_interagir_do_player.visible = false

	_fechar_forja()


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:

	canvass = canvas 
