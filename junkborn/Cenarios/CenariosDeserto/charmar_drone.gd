extends Area2D

var perto: bool = false
var ja_ativado: bool = false # Trava de segurança para executar apenas uma vez

var drone = preload("res://Inimigo/Drone/drone.tscn")
@onready var colisao = $CollisionShape2D



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Só executa se estiver perto E se ainda não foi ativado
	if perto and not ja_ativado:
		ja_ativado = true # Trava imediatamente para não rodar de novo no próximo frame
		ChamarDrone()
		colisao.disabled = true
		
		# Opcional: Se essa área for um gatilho de uso único (tipo uma armadilha), 
		# você pode deletá-la da cena depois de um tempo ou imediatamente:
		# queue_free()
	
func ChamarDrone() -> void:
	for i in 2:
		var a = drone.instantiate()
		# Dica: se o drone for adicionado como filho da Área, ele vai nascer grudado nela 
		# e se mover junto se a área se mover. Se quiser que eles fiquem soltos no mundo, 
		# é melhor usar: get_parent().add_child(a) e definir a global_position.
		add_child(a)
		

func _on_area_entered(area: Area2D) -> void:
	# Verifica se quem entrou foi o Player (evita ativar com tiros ou outras áreas)
	if area.is_in_group("Player") or area.name == "Interagir": # Ajuste conforme sua estrutura de grupos
		perto = true
