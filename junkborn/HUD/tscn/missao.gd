extends Label

func _process(_delta: float) -> void:
	atualizar_texto_missoes()

func atualizar_texto_missoes() -> void:
	var texto_final = "--- MISSÕES ATIVAS ---\n"
	
	# Pega todas as missões do nosso Gerenciador Global
	for missao in GerenciadorMissoes.missoes_ativas:
		if not missao.concluida:
			texto_final += "• " + missao.titulo + "\n  " + missao.descricao + "\n\n"
	
	# Joga o texto montado na Label
	text = texto_final
