extends StaticBody2D

# NPC fixo: nao deve participar de colisoes como CharacterBody2D movel.
# A Area2D filha continua responsavel pelas conversas ao apertar E.
func _ready() -> void:
	$AnimatedSprite2D.play()
