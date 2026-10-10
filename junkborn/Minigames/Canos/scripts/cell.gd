extends Node2D

enum TipoTerreno {
	TERRA_COM_BURACO,
	PEDRA_COM_BURACO,
	PEDRA,
	TERRA,
	TERRA_PEDRA_COM_BURACO,
	PEDRA_CONTAMINADA,
	TERRA_CONTAMINADA
}

enum TipoCano {
	RETO,
	CURVA,
	CRUZ
}

var cavado = false

var duro = false
var cavadas = 0

var tipo_terreno = TipoTerreno.TERRA_COM_BURACO

@onready var terreno = $Terreno

var cano_colocado = false
var tipo_cano = TipoCano.RETO
var eh_fonte = false
var coluna = 0
var linha = 0
var agua_chegou = false


func definir_terreno(novo_tipo):
	tipo_terreno = novo_tipo

	match tipo_terreno:
		TipoTerreno.TERRA_COM_BURACO:
			terreno.region_rect = Rect2(0, 0, 48, 48)
		TipoTerreno.PEDRA_COM_BURACO:
			terreno.region_rect = Rect2(48, 0, 48, 48)
		TipoTerreno.PEDRA:
			terreno.region_rect = Rect2(96, 0, 48, 48)
		TipoTerreno.TERRA:
			terreno.region_rect = Rect2(144, 0, 48, 48)
		TipoTerreno.TERRA_PEDRA_COM_BURACO:
			terreno.region_rect = Rect2(0, 48, 48, 48)
		TipoTerreno.PEDRA_CONTAMINADA:
			terreno.region_rect = Rect2(48, 48, 48, 48)
		TipoTerreno.TERRA_CONTAMINADA:
			terreno.region_rect = Rect2(96, 48, 48, 48)


func pode_receber_cano():
	if eh_fonte or eh_mina() or tipo_terreno == TipoTerreno.PEDRA:
		return false

	return cavado


func cavar():
	if eh_fonte or eh_mina() or cavado or cano_colocado:
		return

	if tipo_terreno == TipoTerreno.PEDRA:
		return

	if duro:
		cavadas += 1

		if cavadas < 2:
			terreno.modulate = Color(0.5, 0.5, 0.6)
			return

		terreno.modulate = Color.WHITE

		if randf() < 0.5:
			terreno.region_rect = Rect2(48, 0, 48, 48)
		else:
			terreno.region_rect = Rect2(0, 48, 48, 48)
	else:
		terreno.region_rect = Rect2(0, 0, 48, 48)

	cavado = true
	
	var escala = terreno.scale
	terreno.scale = escala * 0.85
	create_tween().tween_property(terreno, "scale", escala, 0.12)

func _ready():
	$Cano.visible = false
	$AreaClique.input_event.connect(_quando_clicou)



func _quando_clicou(viewport, event, shape_idx):
	if not get_parent().jogando:
		return

	if not (event is InputEventMouseButton and event.pressed):
		return

	var esquerdo = event.button_index == MOUSE_BUTTON_LEFT
	var direito = event.button_index == MOUSE_BUTTON_RIGHT

	if not esquerdo and not direito:
		return

	# Mina: derrota com qualquer um dos dois botões
	if eh_mina():
		get_parent().derrotar_jogo("mina")
		return

	if direito:
		cavar()
		return

	# Botão esquerdo
	if cano_colocado:
		if agua_chegou:
			return

		$Cano.rotation_degrees = wrapi(
			int($Cano.rotation_degrees) + 90,
			0,
			360
		)
	elif cavado:
		get_parent().tentar_colocar_cano(self)

func definir_cano(tipo):
	tipo_cano = tipo

	match tipo:
		TipoCano.RETO:
			$Cano.region_rect = Rect2(48, 48, 48, 48)
		TipoCano.CURVA:
			$Cano.region_rect = Rect2(0, 0, 48, 48)
		TipoCano.CRUZ:
			$Cano.region_rect = Rect2(48, 0, 48, 48)

	$Cano.rotation_degrees = 0
	$Cano.visible = true
	cano_colocado = true


func marcar_fonte():
	eh_fonte = true
	$Cano.visible = false


func obter_conexoes():
	if not cano_colocado:
		return []

	var rotacao = int(round($Cano.rotation_degrees)) % 360

	match tipo_cano:
		TipoCano.RETO:
			if rotacao == 0 or rotacao == 180:
				return ["cima", "baixo"]
			else:
				return ["esquerda", "direita"]

		TipoCano.CURVA:
			if rotacao == 0:
				return ["esquerda", "baixo"]
			elif rotacao == 90:
				return ["cima", "esquerda"]
			elif rotacao == 180:
				return ["cima", "direita"]
			else:
				return ["baixo", "direita"]

		TipoCano.CRUZ:
			return ["cima", "direita", "baixo", "esquerda"]

	return []


func definir_posicao(nova_coluna, nova_linha):
	coluna = nova_coluna
	linha = nova_linha


func eh_mina() -> bool:
	return tipo_terreno == TipoTerreno.PEDRA_CONTAMINADA \
		or tipo_terreno == TipoTerreno.TERRA_CONTAMINADA


func colocar_cano(tipo):
	definir_cano(tipo)

func ocultar_mina():
	var tween = create_tween()
	tween.tween_property(terreno, "modulate:a", 0.2, 0.15)
	tween.tween_callback(func():
		terreno.region_rect = Rect2(144, 0, 48, 48)
	)
	tween.tween_property(terreno, "modulate:a", 1.0, 0.15)


func mostrar_mina():
	terreno.modulate.a = 1.0

	if tipo_terreno == TipoTerreno.PEDRA_CONTAMINADA:
		terreno.region_rect = Rect2(48, 48, 48, 48)
	else:
		terreno.region_rect = Rect2(96, 48, 48, 48)
		
func definir_duro():
	duro = true
	terreno.modulate = Color(0.72, 0.72, 0.8)
