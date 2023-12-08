extends Control

@onready var menuBaixo = get_node("MenuH")
@onready var boxBusca = get_node("Caixa de Busca")
@onready var listaResultados = get_node("ScrollContainer/ListaResultadosBusca")
@onready var preloadBox = preload("res://Recursos/Box/BoxMedicamentoPesquisa.tscn")
#BoxRemedio
@onready var popNome = get_node("JanelaPOP/BoxPop/NomeBox/ValorSubstancia")
@onready var popSubstancia = get_node("JanelaPOP/BoxPop/SubstanciaBox/ValorSubstancia")
@onready var popFabricante = get_node("JanelaPOP/BoxPop/FabricanteBox/OptionButton")
@onready var popDosagem = get_node("JanelaPOP/BoxPop/DosagemBox/ValorDosagens")
@onready var popClasse = get_node("JanelaPOP/BoxPop/ClasseBox/ValorDosagens")
@onready var popTarja = get_node("JanelaPOP/BoxPop/TarjaBox/ValorDosagens")
@onready var popTipo = get_node("JanelaPOP/BoxPop/TipoBox/ValorDosagens")
@onready var popPreco = get_node("JanelaPOP/BoxPop/EstimativaBox/ValorDosagens")
@onready var popLegal = get_node("JanelaPOP/BoxPop/VendaLiberada/ValorDosagens")
var popIDFabricante = 0
var daraRemedioPop = {}
var buscarSubstancia = false #1 por nome 2 por substancia

func monstraPopUpInfo(nomeRemedio):
	$JanelaPOP.visible = true
	popIDFabricante = 0
	daraRemedioPop = BancoDeDados._dataRemedio(nomeRemedio)
	popNome.clear()
	for fab in daraRemedioPop:
		popNome.add_item(fab.produto)
	attPopInfo()

func attPopInfo():
	#popNome.text = daraRemedioPop[popIDFabricante].produto
	popSubstancia.text = daraRemedioPop[popIDFabricante].substancia
	popSubstancia.text = popSubstancia.text.replace(";","\n")
	popDosagem.text = daraRemedioPop[popIDFabricante].apresentacao
	popClasse.text = daraRemedioPop[popIDFabricante].classe.replace("/","\n")
	popTarja.text = daraRemedioPop[popIDFabricante].tarja.replace("Tarja ","")
	popTipo.text = daraRemedioPop[popIDFabricante].tipo
	popFabricante.text = daraRemedioPop[popIDFabricante].laboratorio
	popPreco.text = daraRemedioPop[popIDFabricante].estimativa
	if (len(popPreco.text) >= 9) or (len(popPreco.text) <= 1):
		popPreco.text = "Sem cadastro"
	else:
		popPreco.text = "R$ "+popPreco.text 
	popLegal.text = daraRemedioPop[popIDFabricante].liberado2022
	#$JanelaPOP/BoxPop/FabricanteBox/OptionButton.add_item()
	#$JanelaPOP/BoxPop/FabricanteBox/OptionButton.get_item_id()
	#$JanelaPOP/BoxPop/FabricanteBox/OptionButton.select()

# Called when the node enters the scene tree for the first time.
func _ready():
	menuBaixo.connect("BotaoMenu",menuPrincipal)
	$JanelaPOP.visible = false
	#Recalcular fundo da janela
	#var x = 1080 / $JanelaPOP.size.x
	#var y = 1920 / $JanelaPOP.size.y
	#$JanelaPOP/FundoBranco.scale.x = x
	#$JanelaPOP/FundoBranco.scale.x = y

func menuPrincipal():
	get_tree().change_scene_to_file("res://Tela/tela_principal.tscn")

func clearBox():
	for filhos in listaResultados.get_children():
		filhos.queue_free()

func addRemedio(nome):
	var caixa = preloadBox.instantiate()
	caixa._setNomeRemedio(nome)
	caixa.connect("abrirPop", monstraPopUpInfo)
	listaResultados.add_child(caixa)

func addSubstancia(nome):
	var caixa = preloadBox.instantiate()
	caixa._setNomeRemedio(nome)
	caixa.connect("abrirPop", monstraPopUpInfo)
	listaResultados.add_child(caixa)

func _on_caixa_de_busca_text_changed(new_text):
	$JanelaPOP.visible = false
	if len(new_text) >= 2:
		clearBox()
		if not buscarSubstancia:
			for med in BancoDeDados._buscaRemedio(new_text):
				addRemedio(med)
		else:
			for med in BancoDeDados._buscaSubstancia(new_text):
				addSubstancia(med)
	else:
		clearBox()


func _on_window_close_requested():
	$JanelaPOP.visible = false


func _on_option_button_item_selected(index):
	popIDFabricante = index
	attPopInfo()


func _on_link_button_pressed():
	buscarSubstancia = not buscarSubstancia
	if buscarSubstancia:
		$LabelMedicamentos.text = "Substancia:"
	else:
		$LabelMedicamentos.text = "Medicamentos:"
	popIDFabricante = 0
	daraRemedioPop = {}
	clearBox()


func _on_buscar_substancia_pressed():
	var subsTemp = daraRemedioPop[popIDFabricante].substancia
	if not buscarSubstancia:
		_on_link_button_pressed()
	else:
		clearBox()
		popIDFabricante = 0
		daraRemedioPop = {}
	$"Caixa de Busca".text = subsTemp
	_on_caixa_de_busca_text_changed(subsTemp)