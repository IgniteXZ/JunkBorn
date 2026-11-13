class_name ItemData
extends Resource

@export var id: int
@export var nome: String
@export var textura: Texture2D
@export var id_item_mapa: String 
@export var tipo: String = "geral" # Adicione isso para diferenciar (ex: "semente", "recurso", etc.)
@export var planta_scene: PackedScene # (Opcional) A cena da planta que vai nascer
