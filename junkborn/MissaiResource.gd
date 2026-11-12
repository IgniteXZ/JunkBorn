class_name  MissaoR
extends Resource

@export var id_missao: String      
@export var titulo: String         
@export_multiline var descricao: String 
@export var concluida: bool = false


@export var destinos_mapa: Array[DestinoMissaoMapa] = []
