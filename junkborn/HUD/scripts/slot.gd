extends Control

# Exporta uma variável do tipo 'LixoData' (recurso customizado) para guardar os dados do item neste slot
@export var item_data: LixoData
# Variável auxiliar para guardar temporariamente os dados caso o jogador cancele o arrasto
var drag_backup = null



# Função nativa do Godot chamada automaticamente quando o jogador começa a arrastar este nó
func _get_drag_data(position: Vector2):
	print("DEBUG DRAG - Conteúdo de item_data no slot: ", item_data)
	
	# Se o slot estiver vazio (sem textura), impede o arrasto retornando null
	if $sprite.texture == null:
		return null
		
	# Cria um Dicionário contendo os dados do item que estão sendo arrastados
	var data := {
		"sprite" : $sprite.texture,
		"amount" : $amount.text,
		"backup" : self,       # Guarda uma referência para este próprio slot (para caso precise reverter)
		"item"   : item_data   # Guarda os dados do recurso do item
	}

	# Salva os dados no backup temporário
	drag_backup = data

	# Cria visualmente a miniatura (preview) que segue o mouse durante o arrasto
	var preview := TextureRect.new()
	preview.texture = $sprite.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(60, 60)

	# Cria um container invisível para centralizar a textura no cursor do mouse
	var preview_container := Control.new()
	preview_container.add_child(preview)
	preview.position = -(preview.size / 2.0)

	# Esvazia o slot de origem imediatamente enquanto o item está sendo arrastado
	set_empty_slot()
	
	# Define a miniatura criada como a imagem visual do arrasto
	set_drag_preview(preview_container)

	# Retorna os dados para o sistema de drag and drop do Godot
	return data

# Função auxiliar para limpar completamente o slot atual
func set_empty_slot() -> void:
	$sprite.texture = null
	$amount.text = ""
	item_data = null

# Função nativa do Godot que valida se este slot pode receber o item que está sendo solto em cima dele
func _can_drop_data(position: Vector2, data) -> bool:
	# Retorna verdadeiro apenas se os dados existirem e tiverem uma sprite válida
	return data != null and data.has("sprite") and data["sprite"] != null

# Função nativa do Godot executada quando o jogador solta (drop) um item em cima deste slot
func _drop_data(position: Vector2, data) -> void:
	# Verifica se o item que está sendo solto é EXATAMENTE IGUAL ao item que já está neste slot
	if $sprite.texture == data.sprite:
		# Se for igual, soma as quantidades (empilhamento)
		var drop_item = int($amount.text)
		drop_item += int(data.amount)
		$amount.text = str(drop_item)
		
		# Garante que o item_data seja mantido se estivesse vazio
		if item_data == null and "item" in data:
			item_data = data["item"]
	else:
		# Se os itens forem diferentes, faz a troca (swap) de posições
		# O conteúdo atual deste slot vai para o slot de origem de onde o item veio (o backup)
		data.backup.get_node("sprite").texture = $sprite.texture
		data.backup.get_node("amount").text = $amount.text
		if "item_data" in data.backup:
			data.backup.item_data = item_data
		
		# O item que estava sendo arrastado assume o lugar neste slot
		$sprite.texture = data.sprite
		$amount.text = data.amount
		if "item" in data:
			item_data = data["item"]
			
	# Se o inventário principal tiver a função de salvar, atualiza o arquivo de save automaticamente
	if has_node("../../..") and get_node("../../..").has_method("salvar_inventario"):
		get_node("../../..").salvar_inventario()

# Função nativa do Godot que monitora eventos globais de notificação (como o término de um arrasto)
func _notification(what):
	# Executado no exato momento em que o arrasto é encerrado (soltando em qualquer lugar da tela)
	if what == NOTIFICATION_DRAG_END:
		# Se o arrasto NÃO foi bem-sucedido (ex: o jogador soltou o item no nada, fora de um slot válido)
		if not get_viewport().gui_is_drag_successful() and drag_backup != null:
			# Devolve o item de volta para este slot usando os dados do backup
			$sprite.texture = drag_backup["sprite"]
			$amount.text = drag_backup["amount"]
			if "item" in drag_backup:
				item_data = drag_backup["item"]
				
			# Salva o inventário para registrar que o item retornou ao lugar
			if has_node("../../..") and get_node("../../..").has_method("salvar_inventario"):
				get_node("../../..").salvar_inventario()

		# Limpa a variável de backup após finalizar o processo
		drag_backup = null
