extends "res://NPC/ScriptsNPC/interacao_dialogo.gd"

# Antes de liberar a saida da Fonte: cair automaticamente com caifonte.
# Depois: o jogador aperta E, sem repetir caifonte.
func _ready() -> void:
    automatico = not Dialogic.VAR.get_variable("podeSairFonte", false)
    # O estado da historia substitui a regra de uso unico. Assim a entrada
    # continua funcionando quando o jogador revisita a Fonte.
    uma_vez = false
    super._ready()
