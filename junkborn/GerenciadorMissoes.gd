extends Node

# Lista com todas as missões ativas no seu diário/jogo
@export var missoes_ativas: Array[MissaoR] = []

# Função para adicionar uma missão na lista
func adicionar_missao(missao: MissaoR):
	if not missoes_ativas.has(missao):
		missoes_ativas.append(missao)

# Função para completar uma missão
func completar_missao(id: String):
	for missao in missoes_ativas:
		if missao.id_missao == id:
			missao.concluida = true
			# Aqui você pode chamar uma função para atualizar a Label na tela
