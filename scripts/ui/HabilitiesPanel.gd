extends Panel

@onready var close_global: Button = $X
@onready var window_title_label: Label = $Label

@onready var melee_attack_btn: Button = $VBoxContainer/Melee
@onready var range_attack_btn: Button = $VBoxContainer/Range
@onready var special_attack_btn: Button = $VBoxContainer/Special

@onready var info_panel: Panel = $InfoPanel
@onready var close_info: Button = $InfoPanel/X
@onready var info_title: Label = $InfoPanel/AttackType
@onready var info_text: Label = $InfoPanel/Info

@export var melee_astronaut: String = "1TODO: EXPLAIN"
@export var melee_q: String = "1TODO: EXPLAIN"
@export var range_astronaut: String = "2TODO: EXPLAIN"
@export var range_q: String = "2TODO: EXPLAIN"
@export var special_astronaut: String = "3TODO: EXPLAIN"
@export var special_q: String = "3TODO: EXPLAIN"

@onready var melee_astronaut_showcase: Control = $InfoPanel/Showcase/Classic_Melee
@onready var melee_q_showcase: Control = $InfoPanel/Showcase/Quantic_Melee
@onready var range_astronaut_showcase: Control = $InfoPanel/Showcase/Classic_Range
@onready var range_q_showcase: Control = $InfoPanel/Showcase/Quantic_Range
@onready var special_astronaut_showcase: Control = $InfoPanel/Showcase/Classic_Special
@onready var special_q_showcase: Control = $InfoPanel/Showcase/Quantic_Special

var descriptions = {}
var curr_character_descriptions  #NOTE: Table with the values from above
var curr_representation: Control

func _ready() -> void:
	close_global.button_up.connect(close_panel.bind(true))
	close_info.button_up.connect(close_panel.bind(false))
	
	descriptions[ProyectilesManager.ProyectileType.CLASSIC] = {\
		"WINDOW_TITLE": "ASTRONAUT",
		"Melee": {
			"TEXT": melee_astronaut,
			"SHOWCASE": melee_astronaut_showcase
		},
		"Range": {
			"TEXT": range_astronaut,
			"SHOWCASE": range_astronaut_showcase
		},
		"Special": {
			"TEXT": special_astronaut,
			"SHOWCASE": special_astronaut_showcase
		}
	}
	descriptions[ProyectilesManager.ProyectileType.QUANTIC] = {\
		"WINDOW_TITLE": "QUARK",
		"Melee": {
			"TEXT": melee_q,
			"SHOWCASE": melee_q_showcase
		},
		"Range": {
			"TEXT": range_q,
			"SHOWCASE": range_q_showcase
		},
		"Special": {
			"TEXT": special_q,
			"SHOWCASE": special_q_showcase
		}
	}
	curr_character_descriptions = descriptions[ProyectilesManager.ProyectileType.CLASSIC]
	
	
	melee_attack_btn.button_up.connect(show_info.bind("Melee"))
	range_attack_btn.button_up.connect(show_info.bind("Range"))
	special_attack_btn.button_up.connect(show_info.bind("Special"))

func set_character(type: ProyectilesManager.ProyectileType):
	curr_character_descriptions = descriptions[type]
	#print("DEBUG: Updated descriptions: " + str(curr_character_descriptions))
	window_title_label.text = curr_character_descriptions.WINDOW_TITLE

func close_panel(is_top_panel: bool):
	curr_representation.visible = false
	info_panel.visible = false
	if is_top_panel:
		visible = false

func show_info(type: String):
	var main_text = curr_character_descriptions[type].TEXT
	var showcase = curr_character_descriptions[type].SHOWCASE
	
	info_title.text = type
	info_text.text = main_text
	curr_representation = showcase
	curr_representation.visible = true
	info_panel.visible = true

func _exit_tree() -> void:
	close_global.button_up.disconnect(close_panel)
	close_info.button_up.disconnect(close_panel)
	melee_attack_btn.button_up.disconnect(show_info)
	range_attack_btn.button_up.disconnect(show_info)
	special_attack_btn.button_up.disconnect(show_info)
