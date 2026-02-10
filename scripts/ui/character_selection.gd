extends CanvasLayer

@onready var swapRight1 : Button = $ButtonR1
@onready var swapRight2: Button = $ButtonR2
@onready var swapLeft1 : Button = $ButtonL1
@onready var swapLeft2: Button = $ButtonL2
@onready var playButton : Button = $ButtonPlay
@onready var backToMenuButton: Button = $BackMenu

@onready var p2_name_text: Label = $HBoxContainer/VBoxContainer2/P2Label

@onready var P1Sprite : AnimatedSprite2D = $HBoxContainer/VBoxContainer/Control/P1Sprite
@onready var P2Sprite : AnimatedSprite2D = $HBoxContainer/VBoxContainer2/Control/P2Sprite

var characters1 : Array[int] = [ProyectilesManager.ProyectileType.CLASSIC, ProyectilesManager.ProyectileType.QUANTIC]
var characters2 : Array[int] = [ProyectilesManager.ProyectileType.CLASSIC, ProyectilesManager.ProyectileType.QUANTIC]
var char1selection : int = 0
var char2selection : int = 0
var solo_play_game: bool = false

func _exit_tree() -> void:
	swapRight1.button_up.disconnect(swap_right1)
	swapRight2.button_up.disconnect(swap_right2)
	swapLeft1.button_up.disconnect(swap_left1)
	swapLeft2.button_up.disconnect(swap_left2)
	playButton.button_up.disconnect(play_game)
	backToMenuButton.button_up.disconnect(return_to_menu)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swapRight1.button_up.connect(swap_right1)
	swapRight2.button_up.connect(swap_right2)
	swapLeft1.button_up.connect(swap_left1)
	swapLeft2.button_up.connect(swap_left2)
	playButton.button_up.connect(play_game)
	backToMenuButton.button_up.connect(return_to_menu)

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
	SignalContainer.game_start.emit(characters1[char1selection], characters2[char2selection], solo_play_game)

func swap_right1() -> void:
	char1selection += 1
	if char1selection < 0:
		char1selection = characters1.size() - 1
	char1selection = char1selection % characters1.size()
	P1Sprite.play(str("idle",char1selection))
	#print("idle",char1selection)

func swap_left1() -> void:
	char1selection -= 1
	if char1selection < 0:
		char1selection = characters1.size() - 1
	char1selection = char1selection % characters1.size()
	P1Sprite.play(str("idle",char1selection))
	#print("idle",char1selection)

func swap_right2() -> void:
	char2selection += 1
	if char2selection < 0:
		char2selection = characters2.size() - 1
	char2selection = char2selection % characters2.size()
	P2Sprite.play(str("idle",char2selection))
	#print("idle",char2selection)

func swap_left2() -> void:
	char2selection += 1
	if char2selection < 0:
		char2selection = characters2.size() - 1
	char2selection = char2selection % characters2.size()
	P2Sprite.play(str("idle",char2selection))
	#print("idle",char2selection)
