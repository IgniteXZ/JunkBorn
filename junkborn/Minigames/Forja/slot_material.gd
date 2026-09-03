extends PanelContainer
class_name SlotMaterial

var textura_obrigatoria: Texture2D = null
var quantidade_obrigatoria: int = 0
var item_colocado_corretamente: bool = false

@onready var icone_material = $IconeMaterial
@onready var texto_quantidade = $textoQuantidade

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if item_colocado_corretamente:
		return false
		
	if data is Dictionary and data.has("sprite") and data.has("amount"):
		if data["sprite"] == textura_obrigatoria:
			var quantidade_jogador = int(data["amount"])
			if quantidade_jogador >= quantidade_obrigatoria:
				return true
	return false

func _drop_data(_position: Vector2, data: Variant) -> void:
	item_colocado_corretamente = true
	
	icone_material.modulate = Color(1, 1, 1, 1)
	
	var quantidade_jogador = int(data["amount"])
	var sobra = quantidade_jogador - quantidade_obrigatoria
	
	if sobra > 0:
		data["backup"].get_node("amount").text = str(sobra)
		data["backup"].get_node("sprite").texture = textura_obrigatoria
	else:
		data["backup"].get_node("sprite").texture = null
		data["backup"].get_node("amount").text = ""
		
	var tela_principal = owner
	if tela_principal and tela_principal.has_method("verificar_todas_as_receitas"):
		tela_principal.verificar_todas_as_receitas()
