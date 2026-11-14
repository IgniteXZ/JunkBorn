extends Resource
class_name RecipeData

@export var nome_resultado: String
@export var icone_resultado: Texture2D
@export var item_resultado: LixoData
@export var ingredientes: Dictionary = {}

@export_multiline var descricao_resultado: String = ""


func texto_resultado() -> String:
	if descricao_resultado.strip_edges() == "":
		return ""
	return nome_resultado + "\n" + descricao_resultado
	
@export var nomes_materiais: Array[String] = []

func nome_material(indice: int) -> String:
	if indice >= 0 and indice < nomes_materiais.size():
		return nomes_materiais[indice]
	return ""
