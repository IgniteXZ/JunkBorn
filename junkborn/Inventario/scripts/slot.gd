extends Control
#serve para arrastar o que nosso criador chama de itens(skibd toiled)
func _get_drag_data(at_position: Vector2) -> Variant:
#não sei para que serve mas não mexe
	var data
	
#cria duplicata(do item seus animal de teta, isso não é um anolog horror) e pré vizualiza a mesma
	var preview = self.duplicate()
#faz com que apenas o item seja movido
	preview.get_node("background").hide()
	preview.get_node("amount").hide()
	
#deixa o item no centro da sua bunda... digo mouse
	preview.get_node("sprite").position = -preview.size/2

	set_drag_preview(preview)
	return preview.get_node("sprite").texture 
#agora vamos dropar o tungtung sarrur celestial

#verifica se pode dar aquela dropada
func can_drop_data(position: Vector2, data) -> bool:
	
	return true
#da aquela dropada	
func  drop_data(position: Vector2, data) -> void:
	$sprite.texture = data
	
