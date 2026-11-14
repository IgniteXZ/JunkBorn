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
	
	if Global.cidade_atual == 0:
		limit_bottom = 400
		limit_right = 1600
	elif Global.cidade_atual ==1:
		limit_bottom =1550
		limit_right = 1595
		limit_left = -3345
	elif Global.cidade_atual ==2:
		limit_bottom =1550
		limit_top = -1440
		limit_right = 1595
		limit_left = -4345
	elif Global.cidade_atual ==4:
		limit_bottom =590
		limit_right = 90
		limit_left = -1575
	elif  Global.cidade_atual == 5:
		limit_bottom =975
		limit_right = 785
		limit_left = -6532
		
		
	drag_horizontal_enabled = true
	
	drag_vertical_enabled = true
