extends Area2D

signal MandarAura(posicaoGlobal: Vector2)
signal TirarAura(Tirar: bool)

var perseguir: bool = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if perseguir:
		#print(player.global_position)
		MandarAura.emit(player.global_position)

func _alguem_entrou(area: Area2D) -> void:
	#print(area)
	#print(area.global_position)
	
	if area.name == "Interagir":
		player = area
		perseguir = true
		
	
	else:
		return

func _alguem_saiu(area: Area2D) -> void:
	if area.name == "Interagir":
		player = null
		perseguir = false
		TirarAura.emit(perseguir)
		
