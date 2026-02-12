extends CanvasLayer


@onready var swapRight = $ButtonR
@onready var swapLeft = $ButtonL

@onready var playButton : Button = $ButtonPlay
@onready var backButton: Button = $ButtonBack

@onready var MapPeek : TextureRect = $Control/MapPeek
@onready var MapName: Label = $Control/MapName

var p1_type: ProyectilesManager.ProyectileType
var p2_type: ProyectilesManager.ProyectileType
var solo: bool
var recolorP1 : bool
var recolorP2 : bool

var selected : int = 0

var MapsTextures : Array[String] = ["res://assets/sprites/Maps/map1.png", "res://assets/sprites/Maps/nonexistentMap.png"]
var MapsNames : Array[String] = ["Map1", "Procedural Map"]


func _exit_tree() -> void:
	swapRight.button_up.disconnect(swap_right)
	swapLeft.button_up.disconnect(swap_left)
	playButton.button_up.disconnect(play_game)
	backButton.button_up.disconnect(return_to_character_selection)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swapRight.button_up.connect(swap_right)
	swapLeft.button_up.connect(swap_left)
	playButton.button_up.connect(play_game)
	backButton.button_up.connect(return_to_character_selection)

func setup(INp1_type: ProyectilesManager.ProyectileType, INp2_type: ProyectilesManager.ProyectileType, INsolo: bool, INrecolorP1 : bool, INrecolorP2 : bool) -> void:
	p1_type = INp1_type
	p2_type = INp2_type
	solo = INsolo
	recolorP1 = INrecolorP1
	recolorP2 = INrecolorP2


func play_game() -> void:
	SignalContainer.game_start.emit(p1_type, p2_type, solo, recolorP1, recolorP2, selected)

func swap_right() -> void:
	selected += 1
	if selected < 0:
		selected = MapsNames.size() - 1
	selected = selected % MapsNames.size()
	MapPeek.texture = load(MapsTextures[selected])
	MapName.text = MapsNames[selected]

func swap_left() -> void:
	selected -= 1
	if selected < 0:
		selected = MapsNames.size() - 1
	selected = selected % MapsNames.size()
	MapPeek.texture = load(MapsTextures[selected])
	MapName.text = MapsNames[selected]

func return_to_character_selection() -> void:
	SignalContainer.game_go_back_to_character_selection.emit(solo)
