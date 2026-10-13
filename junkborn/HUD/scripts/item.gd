extends Area2D

var perto: bool = false
var player: Area2D = null

@export var labelinteragir: Label
var canva = null
var canvass: CanvasLayer = null # Boa prática inicializar como null

@export var id_item_mapa: String # id do item no chao

var Id: int = 1

var MissaoTeste = preload("res://Resource/MissaoTeste.tres")
var MissaoDebug = preload("res://Resource/MissaoLegal.tres")


func _ready() -> void:
	if Global.itens_coletados.has(id_item_mapa):
		queue_free()
		return # Sai da função para evitar processar o resto se já foi coletado
		
	# Nota: get_meta retorna o valor, para definir metadados use set_meta("Id", Id)
	set_meta("Id", Id)


func _process(delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
		
		# Verificação de segurança para evitar crash se o canvas não foi passado ainda
		if canvass == null:
			print("Erro: O CanvasLayer (canvass) ainda não foi atribuído!")
			return

		# Tenta adicionar o item ao inventário
		if canvass.add_item_inventory(Id, $sprite.texture):
			
			if not Global.itens_coletados.has(id_item_mapa):
				Global.itens_coletados.append(id_item_mapa)
				
			# Adiciona as missões apenas no momento da coleta/interação bem-sucedida
			GerenciadorMissoes.adicionar_missao(MissaoTeste)
			GerenciadorMissoes.adicionar_missao(MissaoDebug)
			
			labelinteragir.visible = false
			queue_free()


func _on_area_entered(_area: Area2D) -> void:
	perto = true
	player = _area
	if labelinteragir:
		labelinteragir.visible = true


func _on_area_exited(_area: Area2D) -> void:
	perto = false
	player = null
	if labelinteragir:
		labelinteragir.visible = false


func _on_character_passar_canvas(canvas: CanvasLayer) -> void:
	canvass = canvas
