extends CanvasLayer

@onready var swapRight1 = $ButtonR1
@onready var swapRight2 = $ButtonR2
@onready var swapLeft1  = $ButtonL1
@onready var swapLeft2 = $ButtonL2
@onready var playButton : Button = $ButtonPlay
@onready var backToMenuButton: Button = $BackMenu

@onready var swapOriginal1 : Button = $ColorButtons1/ButonOriginal
@onready var swapRecolor1: Button = $ColorButtons1/ButonRecolor
@onready var swapOriginal2 : Button = $ColorButtons2/ButonOriginal
@onready var swapRecolor2: Button = $ColorButtons2/ButonRecolor

var recolor1 : bool = false
var recolor2 : bool = false

@onready var p2_name_text: Label = $HBoxContainer/VBoxContainer2/P2Label

@onready var P1Sprite : AnimatedSprite2D = $HBoxContainer/VBoxContainer/Control/P1Sprite
@onready var P2Sprite : AnimatedSprite2D = $HBoxContainer/VBoxContainer2/Control/P2Sprite

@onready var character_name1: Label = $CharacterName1
@onready var character_name2: Label = $CharacterName2

@onready var habilities_open1: TextureButton = $Habilities1/InfoButton
@onready var habilities_panel1: Panel = $Habilities1/HabilitiesPanel
@onready var habilities_open2: TextureButton = $Habilities2/InfoButton
@onready var habilities_panel2: Panel = $Habilities2/HabilitiesPanel

var character_names = {ProyectilesManager.ProyectileType.CLASSIC: "ASTRONAUT", ProyectilesManager.ProyectileType.QUANTIC: "Q"}

var characters1 : Array[int] = [ProyectilesManager.ProyectileType.CLASSIC, ProyectilesManager.ProyectileType.QUANTIC]
var characters2 : Array[int] = [ProyectilesManager.ProyectileType.CLASSIC, ProyectilesManager.ProyectileType.QUANTIC]
var char1selection : int = 0
var char2selection : int = 1
var solo_play_game: bool = false

func _exit_tree() -> void:
	swapRight1.button_up.disconnect(swap_right1)
	swapRight2.button_up.disconnect(swap_right2)
	swapLeft1.button_up.disconnect(swap_left1)
	swapLeft2.button_up.disconnect(swap_left2)
	playButton.button_up.disconnect(play_game)
	backToMenuButton.button_up.disconnect(return_to_menu)
	
	swapOriginal1.button_up.disconnect(setOriginal1)
	swapRecolor1.button_up.disconnect(setRecolor1)
	swapOriginal2.button_up.disconnect(setOriginal2)
	swapRecolor2.button_up.disconnect(setRecolor2)
	
	habilities_open1.button_up.disconnect(open_panel)
	habilities_open2.button_up.disconnect(open_panel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swapRight1.button_up.connect(swap_right1)
	swapRight2.button_up.connect(swap_right2)
	swapLeft1.button_up.connect(swap_left1)
	swapLeft2.button_up.connect(swap_left2)
	playButton.button_up.connect(play_game)
	backToMenuButton.button_up.connect(return_to_menu)
	
	swapOriginal1.button_up.connect(setOriginal1)
	swapRecolor1.button_up.connect(setRecolor1)
	swapOriginal2.button_up.connect(setOriginal2)
	swapRecolor2.button_up.connect(setRecolor2)
	
	habilities_open1.button_up.connect(open_panel.bind(habilities_panel1))
	habilities_open2.button_up.connect(open_panel.bind(habilities_panel2))

func open_panel(panel: Panel):
	panel.visible = true

func setOriginal1() -> void:
	recolor1 = false
	P1Sprite.play(str("idle",char1selection, "R" if recolor1 else ""))

func setRecolor1() -> void:
	recolor1 = true
	P1Sprite.play(str("idle",char1selection, "R" if recolor1 else ""))

func setOriginal2() -> void:
	recolor2 = false
	P2Sprite.play(str("idle",char2selection,  "R" if recolor2 else ""))

func setRecolor2() -> void:
	recolor2 = true
	P2Sprite.play(str("idle",char2selection,  "R" if recolor2 else ""))


func setup(solo: bool):
	solo_play_game = solo
	if solo:
		p2_name_text.text = "AI PLAYER"
	else:
		p2_name_text.text = "PLAYER 2"

func return_to_menu() -> void:
	SignalContainer.game_go_back_to_main_menu.emit()

func play_game() -> void:
	# Show contdown
	SignalContainer.game_map_selection.emit(characters1[char1selection], characters2[char2selection], solo_play_game, recolor1, recolor2)

func swap_right1() -> void:
	char1selection += 1
	if char1selection < 0:
		char1selection = characters1.size() - 1
	char1selection = char1selection % characters1.size()
	P1Sprite.play(str("idle",char1selection, "R" if recolor1 else ""))
	character_name1.text = character_names[characters1[char1selection]]
	#print("idle",char1selection)

func swap_left1() -> void:
	char1selection -= 1
	if char1selection < 0:
		char1selection = characters1.size() - 1
	char1selection = char1selection % characters1.size()
	P1Sprite.play(str("idle",char1selection,  "R" if recolor1 else ""))
	character_name1.text = character_names[characters1[char1selection]]
	#print("idle",char1selection)

func swap_right2() -> void:
	char2selection += 1
	if char2selection < 0:
		char2selection = characters2.size() - 1
	char2selection = char2selection % characters2.size()
	P2Sprite.play(str("idle",char2selection,  "R" if recolor2 else ""))
	character_name2.text = character_names[characters2[char2selection]]
	#print("idle",char2selection)

func swap_left2() -> void:
	char2selection += 1
	if char2selection < 0:
		char2selection = characters2.size() - 1
	char2selection = char2selection % characters2.size()
	P2Sprite.play(str("idle",char2selection, "R" if recolor2 else ""))
	character_name2.text = character_names[characters2[char2selection]]
	#print("idle",char2selection)
