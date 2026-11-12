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


func _on_empurrado_body_entered(body: Node2D) -> void:
	# A área Empurrado do jogador detecta o corpo físico do drone (collision layer 2).
	if perdendo_itens or not is_instance_valid(body):
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


func _executar_penalidade_drone() -> void:
	var transicao := _obter_transicao()

	# Fecha a tela antes de alterar o inventário e reposicionar o jogador.
	if transicao != null and transicao.has_method("fade_out"):
		await transicao.fade_out()

	var canvas := get_tree().root.find_child("ui_canvas", true, false)
	if canvas != null and canvas.has_method("limpar_inventario_completo"):
		canvas.limpar_inventario_completo()
	else:
		push_error("ui_canvas não encontrado ou sem limpar_inventario_completo().")

	# A jangada também é perdida junto com os demais itens.
	Global.chamarJangada = false

	# Volta ao spawn inicial desta instância/cena.
	if spawn_inicial_definido:
		global_position = posicao_inicial
	else:
		# Fallback para casos em que a colisão ocorre antes da captura do spawn.
		Global.aplicar_spawn(self)

	velocity = Vector2.ZERO
	knockback_vector = Vector2.ZERO
	bodyy = null
	empurrado = false

	# Reabre a cena usando o shader de transição que já existe no projeto.
	if transicao != null and transicao.has_method("fade_in"):
		await transicao.fade_in()

	# A mensagem aparece depois que a imagem volta, sem ficar escondida pelo fade.
	if canvas != null and is_instance_valid(canvas) and canvas.has_method("mostrar_mensagem_perda"):
		canvas.mostrar_mensagem_perda()

	pode_mover = true
	perdendo_itens = false


func _on_empurrado_body_exited(body: Node2D) -> void:
	pass
