class_name LixoData
extends Resource

@export var nome: String = ""
@export_multiline var descricao: String = ""
@export var textura: Texture2D
@export var tipo: String = ""
@export_enum("Vidro", "Algo", "vaisaberUq") var tipoDeLixo: String
@export var Coletavel: bool = true
