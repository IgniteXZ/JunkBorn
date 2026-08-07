extends Control


#serve para arrastar o que nosso criador chama de itens(skibd toiled)
func _get_drag_data(position: Vector2):
#não sei para que serve mas não mexe
	var data :={
		"sprite" : $sprite.texture,
		"amount" : $amount.text,
		"backup" : self ##salvar ambos slots para não substituir

	}
	
#cria duplicata(do item seus animal de teta, isso não é um anolog horror) e pré vizualiza a mesma
	var preview = self.duplicate()
#faz com que apenas o item seja movido
	preview.get_node("background").hide()
	preview.get_node("amount").hide()
	
#deixa o item no centro da sua bunda... digo mouse
	preview.get_node("sprite").position = -preview.size

	set_empty_slot()
	set_drag_preview(preview)
	
	return data
	
#limpar o drag quando arrastar
func set_empty_slot() -> void:
	$sprite.texture = null
	$amount.text = ""
	
#agora vamos dropar o tungtung sarrur celestial

#verifica se pode dar aquela dropada
func _can_drop_data(position: Vector2, data) -> bool:
	
	return true
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
	
