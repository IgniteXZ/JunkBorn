extends Control
# Guarda temporariamente o item que está sendo arrastado.
# Serve para devolver o item caso ele seja solto fora do inventário.
var drag_backup = null

#serve para arrastar o que nosso criador chama de itens(skibd toiled)
func _get_drag_data(position: Vector2):
	
	# Não permite arrastar um slot vazio.
	if $sprite.texture == null:
		return null
#não sei para que serve mas não mexe
	var data :={
		"sprite" : $sprite.texture,
		"amount" : $amount.text,
		"backup" : self ##salvar ambos slots para não substituir

	}
	# Guarda os dados caso o item seja solto fora do inventário.
	drag_backup = data

	
	# ============================================================
	# CÓDIGO ANTIGO
	# ============================================================

	# Antes nós duplicávamos o slot inteiro para criar a imagem
	# que acompanha o mouse durante o arrasto.
	#
	# Problema:
	# self.duplicate() copia não só a imagem do item,
	# mas também o tamanho, layout, background, amount e outras
	# propriedades do slot.
	#
	# Como o slot faz parte de um GridContainer, esse tamanho
	# podia ser recalculado e fazer a imagem aparecer gigante.

	# var preview = self.duplicate()

	# Depois escondíamos o fundo e a quantidade.
	# Mesmo escondidos, eles ainda faziam parte da cópia do slot.

	# preview.get_node("background").hide()
	# preview.get_node("amount").hide()

	# Essa linha tentava mexer na posição do sprite da cópia.
	# Ela será tratada depois quando corrigirmos a centralização.

	# preview.get_node("sprite").position = -preview.size


	# ============================================================
	# CÓDIGO NOVO
	# ============================================================

	# Agora criamos SOMENTE uma imagem para acompanhar o mouse.
	# Não duplicamos mais o slot inteiro.
	var preview := TextureRect.new()

	# Coloca no preview a mesma textura do item que está no slot.
	preview.texture = $sprite.texture

	# Faz o TextureRect ignorar o tamanho original da imagem.
	# Assim nós conseguimos controlar o tamanho manualmente.
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	# Mantém a proporção da imagem.
	# Exemplo: uma espada não fica achatada ou esticada.
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Define um tamanho fixo para o item enquanto está sendo arrastado.
	preview.size = Vector2(60, 60)


# ============================================================
# CENTRALIZAR ITEM NO MOUSE
# ============================================================

# Cria um Control vazio.
# Esse Control será o objeto que a Godot coloca no mouse.
	var preview_container := Control.new()

# Coloca a imagem dentro desse Control.
	preview_container.add_child(preview)

# Move a imagem metade do tamanho para esquerda e para cima.
# Como a imagem é 40x40:
# 40 / 2 = 20
# Então ela anda -20 no X e -20 no Y.
	preview.position = -(preview.size / 2.0)


	set_empty_slot()

# CÓDIGO ANTIGO:
# O próprio preview era colocado no mouse.
# Por isso o mouse ficava no canto superior esquerdo da imagem.
# set_drag_preview(preview)

# CÓDIGO NOVO:
# Agora o container fica no mouse e a imagem fica centralizada dentro dele.
	set_drag_preview(preview_container)

	return data
	
#limpar o drag quando arrastar
func set_empty_slot() -> void:
	$sprite.texture = null
	$amount.text = ""
	
#agora vamos dropar o tungtung sarrur celestial

#verifica se pode dar aquela dropada
func _can_drop_data(position: Vector2, data) -> bool:
	
	# Só aceita um drag que realmente tenha um item.
	return data != null and data.has("sprite") and data["sprite"] != null
			#data != null(confirma que um dado tá sendo arrastado)
			#				data.has("sprite")=confirma que o dado possui um sprite
		#data["sprite"] != null - confirma que existe uma imagem lá
# CÓDIGO ANTIGO:
	# return true
	#
	# Antes qualquer dado era aceito pelo slot.
	# Isso incluía até um drag sem item de verdade,
	# permitindo criar/mover um "item invisível".
	#da aquela dropada	
func  _drop_data(position: Vector2, data) -> void:
	##trocar o lado dos dados de cada item no momento da troca de slot
	##esse if verifica se os dois itens são iguais, se for, eles se juntam
	if $sprite.texture == data.sprite:
		var drop_item = int($amount.text)
		drop_item += int(data.amount)
		$amount.text = str(drop_item)
	else:
		data.backup.get_node("sprite").texture = $sprite.texture
		data.backup.get_node("amount").text = $amount.text
		
		$sprite.texture = data.sprite
		$amount.text = data.amount
#fim da dropada

# ============================================================
# DEVOLVER ITEM SE FOR SOLTO FORA DO INVENTÁRIO
# ============================================================

func _notification(what):

	# Verifica quando o arrasto terminou.
	if what == NOTIFICATION_DRAG_END:

		# Se o item não foi solto em um lugar válido,
		# devolve ele para o slot original.
		if not get_viewport().gui_is_drag_successful() and drag_backup != null:

			$sprite.texture = drag_backup["sprite"]
			$amount.text = drag_backup["amount"]

		# Limpa o backup depois que o arrasto terminou.
		drag_backup = null
	
