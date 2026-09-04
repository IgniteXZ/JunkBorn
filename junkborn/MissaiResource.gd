class_name  MissaoR
extends Resource

@export var id_missao: String        # Ex: "falar_com_npc" ou "matar_slimes"
@export var titulo: String           # Ex: "Ajudar o ferreiro"
@export_multiline var descricao: String # Ex: "Colete 3 madeiras na floresta."
@export var concluida: bool = false
