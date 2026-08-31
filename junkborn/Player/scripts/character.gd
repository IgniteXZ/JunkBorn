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


func _ready() -> void:
	_state_machine = _animation_tree["parameters/playback"]
	

func  _physics_process(_delta: float) -> void:
	_move()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if _direction != Vector2.ZERO:
		_animation_tree["parameters/idle/blend_position"] = _direction
		velocity.x = lerp(velocity.x, _direction.normalized().x * _mover_speed, _aceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _mover_speed, _aceleration)
		return
	velocity.x = lerp(velocity.x, _direction.normalized().x * _mover_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _mover_speed, _friction)
	
func _animate() -> void:
	_state_machine.travel("idle")

func _process(delta: float) -> void:
	PassarCanvas.emit(canvaa)


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
