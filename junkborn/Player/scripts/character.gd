extends CharacterBody2D

#signal DaumaPegadaAqui(global_position: Vector2)

var _state_machine

signal PassarCanvas(canvas:CanvasLayer)

@export var camera: Camera2D

@export_category("Variables")
@export var _mover_speed: float = 140.0

@export var _friction: float = 1
@export var _aceleration: float = 0.2

@export_category("Objects")
@export var _animation_tree: AnimationTree = null
@export var Jangada: LixoData

@export var canvaa: CanvasLayer

var knockback_vector: Vector2 = Vector2.ZERO

var bodyy = null
var empurrado: bool

var tempoAcabado: bool = false

# Posição inicial do jogador nesta cena, depois que o Global aplica o spawn salvo.
var posicao_inicial: Vector2 = Vector2.ZERO
var spawn_inicial_definido: bool = false
var perdendo_itens: bool = false

var pode_mover: bool = true #travar depois em minigames

# Limiar de velocidade para considerar "andando" (evita alternar walk/idle)
const VELOCIDADE_MINIMA_ANIM: float = 5.0


func _ready() -> void:
	# Top-down: evita comportamento de "chão/parede" no move_and_slide
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	# Câmera atualiza junto com a física (evita tremida)
	if camera:
		camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	
	$Animation.speed_scale = 0.2

	_state_machine = _animation_tree["parameters/playback"]

# Define a direção inicial do Filomeno: olhando para baixo
	var direcao_inicial = Vector2(0, 1)

	_animation_tree["parameters/idle/blend_position"] = direcao_inicial
	_animation_tree["parameters/walk/blend_position"] = direcao_inicial
	_animation_tree["parameters/jangada/blend_position"] = direcao_inicial
	_animation_tree["parameters/jangadaIdle/blend_position"] = direcao_inicial

	_state_machine.travel("idle")

	call_deferred("_aplicar_spawn")



func _aplicar_spawn() -> void:
	Global.aplicar_spawn(self)
	# Aguarda um frame para garantir que o spawn definido pelo Global foi aplicado.
	await get_tree().process_frame
	posicao_inicial = global_position
	spawn_inicial_definido = true


func _physics_process(_delta: float) -> void:
	if not pode_mover:
		velocity = Vector2.ZERO
		_animate()
		return

	if empurrado:
		velocity = knockback_vector
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, _friction * 1000 * _delta)
	else:
		_move()
		_animate()

	move_and_slide()


func _move() -> void:
	var _direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	if _direction != Vector2.ZERO:
		# Trava a animação em 4 direções (sem diagonal)
		var _dir_anim: Vector2
		if abs(_direction.x) >= abs(_direction.y):
			_dir_anim = Vector2(sign(_direction.x), 0)
		else:
			_dir_anim = Vector2(0, sign(_direction.y))

		_animation_tree["parameters/idle/blend_position"] = _dir_anim
		_animation_tree["parameters/walk/blend_position"] = _dir_anim
		_animation_tree["parameters/jangada/blend_position"] = _dir_anim
		_animation_tree["parameters/jangadaIdle/blend_position"] = _dir_anim

		velocity = velocity.lerp(_direction * _mover_speed, _aceleration)
		return

	velocity = velocity.lerp(Vector2.ZERO, _friction)


func _animate() -> void:
	var andando: bool = velocity.length() > VELOCIDADE_MINIMA_ANIM

	if andando and Global.chamarJangada:
		$texture.hide()
		$textureJangada.show()
		_state_machine.travel("jangada")
		return

	if andando and not Global.chamarJangada:
		$texture.show()
		$textureJangada.hide()
		_state_machine.travel("walk")
		return
	
	if not andando and Global.chamarJangada:
		$texture.hide()
		$textureJangada.show()
		_state_machine.travel("jangadaIdle")
		return

	_state_machine.travel("idle")


func _process(_delta: float) -> void:
	PassarCanvas.emit(canvaa)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			Global.trocarCenaSemSpawn(
				"res://Cenarios/CenariosDeserto/Deserto1.tscn"
			)
		if event.keycode == KEY_2:
			Global.trocarCenaSemSpawn(
				"res://Cenarios/Cenario Fonte/fonte.tscn"
			)
		if event.keycode == KEY_3:
			Global.trocarCenaSemSpawn(
				"res://Cenarios/cenario desertoFonte/desertoFonte.tscn"
				
			)


func _on_empurrado_body_entered(body: Node2D) -> void:
	# A área Empurrado do jogador detecta o corpo físico do drone (collision layer 2).
	if perdendo_itens or not is_instance_valid(body):
		return
	if not body.is_in_group("drone"):
		return

	# Evita que vários drones iniciem a penalidade ao mesmo tempo.
	perdendo_itens = true
	pode_mover = false
	velocity = Vector2.ZERO
	knockback_vector = Vector2.ZERO
	bodyy = body

	if camera:
		camera.tremer(5.0)

	await _executar_penalidade_drone()


func _obter_transicao() -> Node:
	# Primeiro tenta usar o Autoload existente.
	var transicao := get_tree().root.get_node_or_null("Transicao")
	if transicao != null:
		return transicao

	# Fallback: instancia a mesma cena de transição caso ela não esteja como Autoload.
	var cena_transicao := load("res://Cutsenes/transicao.tscn") as PackedScene
	if cena_transicao == null:
		push_error("Não foi possível carregar res://Cutsenes/transicao.tscn")
		return null

	transicao = cena_transicao.instantiate()
	get_tree().root.add_child(transicao)
	return transicao


# Somente a exploracao do Pantano com a jangada permite teletransporte.
func _exploracao_jangada_ativa() -> bool:
	var cena := get_tree().current_scene
	if cena == null or cena.scene_file_path != "res://Cenarios/Cenario pantano/pantanoQuimico.tscn":
		return false

	var exploracao := cena.get_node_or_null("ExploraJangada")
	return (
		exploracao != null
		and Global.chamarJangada
		and bool(exploracao.get("aberto"))
		and bool(exploracao.get("jogador_dentro"))
	)


func _executar_penalidade_drone() -> void:
	# Captura o contexto antes do fade, pois a colisao pode mudar durante a transicao.
	var deve_retornar: bool = _exploracao_jangada_ativa()
	var cena := get_tree().current_scene
	var exploracao: Node = cena.get_node_or_null("ExploraJangada") if deve_retornar else null
	var destino: Vector2 = posicao_inicial
	if deve_retornar:
		var marcador := cena.get_node_or_null("RetornoDroneJangada") as Marker2D
		if marcador != null:
			destino = marcador.global_position

	# So faz a transicao visual quando houver retorno ao ponto seguro no Pantano.
	# Em um roubo comum, o jogador permanece no mesmo local, sem fade.
	var transicao: Node = null
	if deve_retornar:
		transicao = _obter_transicao()
		if transicao != null and transicao.has_method("fade_out"):
			await transicao.fade_out()

	# A perda de UM item comum acontece em qualquer cena com drones.
	var canvas := get_tree().root.find_child("ui_canvas", true, false)
	var roubou_item := false
	if canvas != null and canvas.has_method("remover_item_aleatorio"):
		roubou_item = canvas.remover_item_aleatorio()
	else:
		push_error("ui_canvas não encontrado ou sem remover_item_aleatorio().")

	if deve_retornar:
		# So recua para a area segura se foi atingido explorando com jangada.
		if spawn_inicial_definido or cena.get_node_or_null("RetornoDroneJangada") != null:
			global_position = destino
		else:
			Global.aplicar_spawn(self)

		if is_instance_valid(exploracao) and exploracao.has_method("encerrar_exploracao_por_drone"):
			exploracao.encerrar_exploracao_por_drone()
		else:
			Global.chamarJangada = false

	velocity = Vector2.ZERO
	knockback_vector = Vector2.ZERO
	bodyy = null
	empurrado = false

	if deve_retornar and transicao != null and transicao.has_method("fade_in"):
		await transicao.fade_in()

	if canvas != null and is_instance_valid(canvas) and canvas.has_method("mostrar_mensagem_perda"):
		canvas.mostrar_mensagem_perda(roubou_item)

	pode_mover = true
	perdendo_itens = false


func _on_empurrado_body_exited(body: Node2D) -> void:
	pass
