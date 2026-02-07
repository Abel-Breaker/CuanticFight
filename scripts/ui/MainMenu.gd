extends Panel

@onready var start_game_btn : Button = $VBoxContainer/Start/Button
@onready var exit_game_btn : Button = $VBoxContainer/Exit/Button

func _ready() -> void:
	start_game_btn.button_up.connect(on_start_pressed)
	exit_game_btn.button_up.connect(on_exit_pressed)

func on_start_pressed():
	SignalContainer.game_start.emit()

func on_exit_pressed():
	SignalContainer.program_close.emit(0)


func _exit_tree() -> void:
	start_game_btn.button_up.disconnect(on_start_pressed)
	exit_game_btn.button_up.disconnect(on_exit_pressed)
