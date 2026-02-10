extends Panel

@onready var start_game_solo_btn : Button = $VBoxContainer/PlaySolo/Button
@onready var start_game_2p_btn: Button = $"VBoxContainer/2Player/Button"
@onready var exit_game_btn : Button = $VBoxContainer/Exit/Button

func _ready() -> void:
	start_game_solo_btn.button_up.connect(on_solo_start_pressed)
	start_game_2p_btn.button_up.connect(on_2p_start_pressed)
	exit_game_btn.button_up.connect(on_exit_pressed)

func on_solo_start_pressed():
	SignalContainer.game_character_selection.emit(true)

func on_2p_start_pressed():
	SignalContainer.game_character_selection.emit(false)

func on_exit_pressed():
	SignalContainer.program_close.emit(0)


func _exit_tree() -> void:
	start_game_solo_btn.button_up.disconnect(on_solo_start_pressed)
	start_game_2p_btn.button_up.disconnect(on_2p_start_pressed)
	exit_game_btn.button_up.disconnect(on_exit_pressed)
