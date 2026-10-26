extends Node

signal missao_adicionada(missao: MissaoR)
signal missao_concluida(missao: MissaoR)

@export var missoes_ativas: Array[MissaoR] = []

func adicionar_missao(missao: MissaoR) -> void:
	if not missoes_ativas.has(missao):
		missoes_ativas.append(missao)
		missao_adicionada.emit(missao)

func completar_missao(id: String) -> void:
	for missao in missoes_ativas:
		if missao.id_missao == id and not missao.concluida:
			missao.concluida = true
			missao_concluida.emit(missao)

# Atalho para o Dialogic e para qualquer script: GerenciadorMissoes.iniciar("dormir")
func iniciar(id: String) -> void:
	var caminho: String = "res://Resource/Missoes/%s.tres" % id
	if ResourceLoader.exists(caminho):
		adicionar_missao(load(caminho))
	else:
		push_warning("Missão não encontrada: " + caminho)
