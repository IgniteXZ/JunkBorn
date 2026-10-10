extends CanvasLayer

@onready var texto_tempo = $PainelInformacoes/Tempo


func atualizar_tempo(segundos):
	texto_tempo.text = "TEMPO: " + str(segundos) + "s"


func atualizar_canos(texto):
	$PainelInformacoes/CanosRestantes.text = "CANOS: " + str(texto)


func atualizar_fase(atual, total):
	$PainelInformacoes/Fase.text = "FASE: %d/%d" % [atual, total]


func atualizar_velocidade(texto):
	$PainelInformacoes/VelocidadeAgua.text = "ÁGUA: " + texto
