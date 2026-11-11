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
	if empurrado:
		return

	empurrado = true
	bodyy = body

	if camera:
		camera.tremer(3.0)

	var canvas = get_tree().root.find_child("ui_canvas", true, false)
	if canvas:
		perderJangada()
		canvas.remover_item_aleatorio()

	var direcaoEmpurra = (global_position - bodyy.global_position).normalized()
	knockback_vector = direcaoEmpurra * 400.0 * 2

	await get_tree().create_timer(0.2).timeout
	empurrado = false
	bodyy = null



	
func perderJangada() -> void:
	var canvas = get_tree().root.find_child("ui_canvas", true, false)
	if canvas == null or not canvas.has_method("remover_itens_por_textura"):
		push_error("Inventário não encontrado ou sem a função 'remover_itens_por_textura'.")
		return

	var qtd: int = canvas.remover_itens_por_textura(Jangada.textura)
	if qtd <= 0:
		print("Você não tem Jangada no inventário!")
		return
	
	# --- NOVO: Verifica se ele estava na jangada quando ela sumiu ---
	# Usando a variável Global que você já usa no _animate()
	if Global.chamarJangada == true:
		position = Vector2(-592.0, -55.0)
		
		# Desliga o estado de jangada
		Global.chamarJangada = false 
		
	
	
	

func _on_empurrado_body_exited(body: Node2D) -> void:
	pass
