extends Camera2D

var podeTremer: bool = false

var _shake_forca: float
var shake_decaimento: float = 8.0

func tremer(forca: float) -> void:
	_shake_forca = forca
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _shake_forca > 0:
		offset = Vector2(
			randf_range(-_shake_forca, _shake_forca),
			randf_range(-_shake_forca, _shake_forca)
		)
		_shake_forca = move_toward(_shake_forca, 0, shake_decaimento * _delta)
	else:
		offset = Vector2.ZERO
