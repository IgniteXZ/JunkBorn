extends CanvasLayer

@export var fundo: ColorRect
@export var titulo: Label

var ativo: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func mostrar(texto: String, cena: String = "", duracao: float = 2.5) -> void:
	ativo = true
	titulo.text = texto
	titulo.modulate.a = 0.0
	fundo.modulate.a = 0.0
	visible = true
	
	var t: Tween = create_tween()
	t.tween_property(fundo, "modulate:a", 1.0, 0.6)
	await t.finished
	
	if Dialogic.current_timeline != null:
		Dialogic.Text.hide_textbox(true)
	
	if cena != "":
		get_tree().change_scene_to_file(cena)
		
	t = create_tween()
	t.tween_property(titulo, "modulate:a", 1.0, 0.6)
	t.tween_interval(duracao)
	t.tween_property(titulo, "modulate:a", 0.0, 0.6)
	t.tween_property(fundo, "modulate:a", 0.0, 0.6)
	await t.finished
	
	visible = false
	ativo = false
	
func aguardar() -> void:
	while ativo:
		await get_tree().process_frame
