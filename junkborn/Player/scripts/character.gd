extends CharacterBody2D

#signal DaumaPegadaAqui(global_position: Vector2)

var _state_machine

signal PassarCanvas(canvas:CanvasLayer)

@export_category("Variables")
@export var _mover_speed: float = 240.0

@export var _friction: float = 1
@export var _aceleration: float = 0.2

@export_category("Objects")
@export var _animation_tree: AnimationTree = null

@export var canvaa: CanvasLayer

var knockback_vector = Vector2.ZERO

var bodyy = null
var empurrado: bool

var tempoAcabado: bool = false

var t: float = 0.0


func _ready() -> void:
	_state_machine = _animation_tree["parameters/playback"]
	

	
func _physics_process(_delta: float) -> void:
	_move()
	_animate()
	
	
	if empurrado:
		#knockback_vector = (bodyy.global_position - global_position) * 0.01
		#velocity = lerp(global_position, -knockback_vector, _delta)
		t += _delta *  0.4
		position = global_position.lerp(bodyy.global_position - -global_position, t)
		await get_tree().create_timer(0.3).timeout
		empurrado = false
		
	elif not empurrado:
		t = 0.0
	move_and_slide()
	


func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if _direction != Vector2.ZERO:
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _mover_speed, _aceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _mover_speed, _aceleration)
		_animation_tree["parameters/Walk/blend_position"] = _direction
		return
	velocity.x = lerp(velocity.x, _direction.normalized().x * _mover_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _mover_speed, _friction)
	#_animation_tree["parameters/Idle/blend_position"] = _direction
func _animate() -> void:
	_state_machine.travel("Walk")
	#_state_machine.travel("Idle")
	
func _process(delta: float) -> void:
	PassarCanvas.emit(canvaa)


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_empurrado_body_entered(body: Node2D) -> void:
	empurrado = true
	bodyy = body
	
	


func _on_empurrado_body_exited(body: Node2D) -> void:
	pass
