class_name LixoData
extends Resource

@export var nome: String = ""
@export_multiline var descricao: String = ""
@export var textura: Texture2D
@export_enum("Vidro", "Metal", "Plastico", "Papel") var tipoDeLixo: String = "Algo"
@export var Coletavel: bool = true
