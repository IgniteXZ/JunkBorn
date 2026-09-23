extends Area2D
var perto: bool = false
var player: Area2D = null
#Em Elbaph, o filho do Rei
#Matou o pai por ambição
#Crucificado pela lei
#A desgraça da nação
#
#Acorrentado, pois não podem trazer minha morte
#Prazer Luffy, eu sou o príncipe de Elbaph, Loki
#Tu não entendeu minha grandeza, eu não sou teu companheiro
#Mas me liberte e eu destruo o que quiser no mundo inteiro
#
#Dogahahahaha
#Vou recusar entrar nesse teu plano
#Me tornar um Cavaleiro de Deus?
#Eu prefiro ficar preso por mais mil anos
#
#Parece com o ruivo, aquele maldito
#Ele é seu irmão? Sua família eu odeio
#Desgraçado, você matou os meus amigos
#Quando eu me libertar, tu vai ser o primeiro
#
#Retornou Monkey D. Luffy
#Hora de cada corrente cair
#É aquilo que dizem do Loki
#Não deixem ele pegar o Ragnir
#
#Nenhum de vocês pode erguer esse martelo
#Irmão, tudo que te contaram é mentira
#Nosso pai em sofrimento eterno
#Me implorou pra que eu tirasse sua vida
#
#O Rei possuído pelo mal
#Fim pro seu sofrimento ponho
#Foi o governo mundial
#O culpado é o próprio demônio
#
#Igual verme o dragão o mundo rói, rói, rói
#Mundo trema, esse dragão é Nidhogg-hogg-hogg
#Atribuíram o fim do mundo a Loki
#Queime o mundo inteiro, Ragnir
#Toquem as trombetas do Ragnarok
#A raiz do mundo irá se partir
#
#Me escute irmão, Mugiwaras
#Permitam-me contar minha história do início
#O filho da Rainha parece um demônio
#Por isso minha mãe me jogou no abismo
#
#O recém-nascido escalou o submundo
#Sem temer o destino que lhe foi imposto
#A raiva e tristeza foi tanta
#Que a Rainha morreu de tanto desgosto
#
#E eu nunca chamaria de mãe
#Pois dentro dela não existia amor
#Mas acolhido por outra mãe
#Só que o povo de Elbaph a envenenou
#
#Fogo a quem merece, então eu queimarei Elbaph
#Me inspirarei em um homem, Rocks D. Xebec
#
#Queria ser igual a ele antes de crescer
#Mas como ele morreu? Me digam, quem que foi capaz?
#Rei, tem algo de muito estranho com você
#Tem certeza mesmo que você é o meu pai?
#
#Se juntou ao demônio por poder?
#O último desejo do papai era morrer
#Ele pediu pra que eu comesse a Akuma no Mi
#Sai da frente, martelo, pois eu tenho uma certa fruta pra comer
#
#O martelo comeu uma fruta e se tornou um esquilo vivo
#Ratatoskr só dará a fruta se esse alguém for digno
#E parece que Loki realmente foi o escolhido
#Sim, matei meu próprio pai e carrego esse ódio comigo
#
#Agora sabem da minha história, mas cansei de flashback
#Tu tá entendendo errado, Mugiwara, não se mete
#Um Haki tão grande que Elbaph inteira estremece
#
#Todos ouviram
#Os tambores que trazem libertação
#Como as lendas dizem
#Nika vai aparecer com um dragão
#
#Poder pra queimar o mundo todo
#Nidhogg é capaz
#Então me tragam o homem que entrou na mente do
#Do meu pai
#
#Dalí que veio esse Haki?
#Demônio, não vai me atingir com essas correntes
#Então parta os céus em raio, Ragnir
#Tá querendo o Regicida? Seu otário, eu tô bem na sua frente
#
#Sua sombra eu reconheço
#De quando o pai morreu
#Desse dia não me esqueço
#Porque meu pai ficou com o mesmo olho que o seu
#
#Foi você que invadiu a mente do Rei
#Venha, demônio do inferno mais profundo
#Pai, prometo que eu ainda te vingarei
#Eu não temo nem o maior demônio do mundo
#
#Thor, então fizemo um demônio sangrar?
#Pode mudar de forma, não vai me amedrontar
#Thor, acho que desse não vai desviar
#Seu desgraçado, vamo ver se tu vai aguentar
#
#Falei que ia pegar leve, é mentira minha
#Tu vai pensar duas vezes antes de pisar em minha ilha
#Tu tava cheio de marra, olha, quem diria
#O tal do próprio demônio tendo que olhar pra cima
#
#Nidhogg e Nika
#Eram rivais verdadeiros
#Até parecem mentira
#Lutando igual companheiros
#
#Igual verme o dragão o mundo rói, rói, rói
#Mundo trema, esse dragão é Nidhogg-hogg-hogg
#Atribuíram o fim do mundo a Loki
#Queime o mundo inteiro, Ragnir
#Toquem as trombetas do Ragnarok
#A raiz do mundo irá se partir

@export var labelInteragir: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if perto and Input.is_action_just_pressed("Interagir"):
			print("gonnei")
			get_tree().change_scene_to_file("res://Cenarios/CenarioDentroCasa/QuartoHeinal.tscn")


func _on_area_entered(area: Area2D) -> void:
	perto = true
	player = area
	labelInteragir.visible = true


func _on_area_exited(area: Area2D) -> void:
	perto = false
	player = null
	labelInteragir.visible = false
