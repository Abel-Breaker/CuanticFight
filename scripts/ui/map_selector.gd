extends CanvasLayer


@onready var swapRight = $ButtonR
@onready var swapLeft = $ButtonL

@onready var playButton : Button = $ButtonPlay
@onready var backButton: Button = $ButtonBack
@onready var OF2P : Label = $OnlyFor2P

@onready var MapPeek : TextureRect = $Control/MapPeek
@onready var MapName: Label = $Control/MapName

@onready var keyboard_change_map_sound: AudioStreamPlayer = $PressDown

var p1_type: ProyectilesManager.ProyectileType
var p2_type: ProyectilesManager.ProyectileType
var solo: bool
var recolorP1 : bool
var recolorP2 : bool

var selected : int = 0

var MapsTextures : Array[String] = [ \
"res://assets/sprites/Maps/BlueMap.png", \
"res://assets/sprites/Maps/GreenMap.png", \
"res://assets/sprites/Maps/RedMap.png", \
"res://assets/sprites/Maps/nonexistentMap.png"]
var MapsNames : Array[String] = [ \
"Qrater, Qave and Mountain", \
"Quiet Mound", \
"Twisting Qaverns", \
"Procedural Map"]


func _exit_tree() -> void:
	swapRight.button_up.disconnect(swap_right)
	swapLeft.button_up.disconnect(swap_left)
	playButton.button_up.disconnect(play_game)
	backButton.button_up.disconnect(return_to_character_selection)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playButton.grab_focus()
	swapRight.button_up.connect(swap_right)
	swapLeft.button_up.connect(swap_left)
	playButton.button_up.connect(play_game)
	backButton.button_up.connect(return_to_character_selection)
	
	MapPeek.texture = load(MapsTextures[selected])
	MapName.text = MapsNames[selected]

func _input(event):
	if swapRight.has_focus() and event.is_action_pressed("ui_right"):
		AudioManager.play_sound_safe(keyboard_change_map_sound)
		swap_right()
	if swapLeft.has_focus() and event.is_action_pressed("ui_left"):
		AudioManager.play_sound_safe(keyboard_change_map_sound)
		swap_left()

func setup(INp1_type: ProyectilesManager.ProyectileType, INp2_type: ProyectilesManager.ProyectileType, INsolo: bool, INrecolorP1 : bool, INrecolorP2 : bool) -> void:
	p1_type = INp1_type
	p2_type = INp2_type
	solo = INsolo
	recolorP1 = INrecolorP1
	recolorP2 = INrecolorP2


func play_game() -> void:
	SignalContainer.game_start.emit(p1_type, p2_type, solo, recolorP1, recolorP2, selected)

func postSwap() -> void:
	if solo:
		if selected == 2:
			playButton.visible = false
			OF2P.visible = true
		else:
			playButton.visible = true
			OF2P.visible = false

func swap_right() -> void:
	selected += 1
	if selected < 0:
		selected = MapsNames.size() - 1
	selected = selected % MapsNames.size()
	MapPeek.texture = load(MapsTextures[selected])
	MapName.text = MapsNames[selected]
	postSwap()

func swap_left() -> void:
	selected -= 1
	if selected < 0:
		selected = MapsNames.size() - 1
	selected = selected % MapsNames.size()
	MapPeek.texture = load(MapsTextures[selected])
	MapName.text = MapsNames[selected]
	postSwap()

func return_to_character_selection() -> void:
	SignalContainer.game_go_back_to_character_selection.emit(solo)
