extends Node

var player: AudioStreamPlayer
var current_tween: Tween # Variável para controlar o tween atual

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.finished.connect(_on_audio_finished)

func _process(_delta: float) -> void:
	if Global.DesligarMusica:
		player.stream_paused = true
	else:
		player.stream_paused = false

func tocar_musica(nova_musica: AudioStream) -> void:
	if not nova_musica:
		return
		
	# Se já for a mesma música tocando E o player estiver ativo, não faz nada
	if player.stream == nova_musica and player.playing:
		return
		
	player.stream = nova_musica
	player.play()
	
	# Cancela tween anterior se houver
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	# Fade in suave
	player.volume_db = -80.0
	current_tween = create_tween()
	current_tween.tween_property(player, "volume_db", 0.0, 3.0)

func _on_audio_finished() -> void:
	if player.stream and not Global.DesligarMusica:
		player.play()

func parar_musica() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	current_tween = create_tween()
	current_tween.tween_property(player, "volume_db", -80.0, 0.7)
	await current_tween.finished
	player.stop()
	
func Continuar_musica() -> void:
	if not player.stream:
		return
		
	if not player.playing:
		player.play()
		
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	current_tween = create_tween()
	current_tween.tween_property(player, "volume_db", 0.0, 3.0)
