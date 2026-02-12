extends Panel

@onready var close_global: Button = $X

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


func _ready() -> void:
	close_global.button_up.connect(close_panel.bind(true))
	close_info.button_up.connect(close_panel.bind(false))
	
	melee_attack_btn.button_up.connect(show_info.bind("Melee", melee_astronaut, melee_q))
	range_attack_btn.button_up.connect(show_info.bind("Range", range_astronaut, range_q))
	special_attack_btn.button_up.connect(show_info.bind("Special", special_astronaut, special_q))


func close_panel(is_top_panel: bool):
	info_panel.visible = false
	if is_top_panel:
		visible = false


func show_info(title: String, astronaut_text: String, q_text: String):
	info_title.text = title
	info_text.text = "Astronaut:\n  "+astronaut_text+"\nQ:\n  "+q_text
	info_panel.visible = true


func _exit_tree() -> void:
	close_global.button_up.disconnect(close_panel)
	close_info.button_up.disconnect(close_panel)
	melee_attack_btn.button_up.disconnect(show_info)
	range_attack_btn.button_up.disconnect(show_info)
	special_attack_btn.button_up.disconnect(show_info)
