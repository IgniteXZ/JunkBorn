extends Node

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Faz a música tocar novamente de forma automática assim que terminar (Loop)
	player.finished.connect(_on_audio_finished)

func _process(_delta: float) -> void:
	if Global.DesligarMusica:
		player.stream_paused = true
	else:
		player.stream_paused = false

func tocar_musica(nova_musica: AudioStream) -> void:
	if not nova_musica:
		return
		
	# Se já for a mesma música tocando, não reinicia
	if player.stream == nova_musica and player.playing:
		return
		
	player.stream = nova_musica
	player.play()
	
	# Fade in suave
	player.volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0.0, 3.0)

# Função chamada automaticamente quando a música acaba
func _on_audio_finished() -> void:
	if player.stream and not Global.DesligarMusica:
		player.play()

func parar_musica() -> void:
	player.stop()
