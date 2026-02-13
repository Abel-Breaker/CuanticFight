extends Panel

@onready var start_game_solo_btn : Button = $VBoxContainer/PlaySolo/Button
@onready var start_game_2p_btn: Button = $"VBoxContainer/2Player/Button"
@onready var exit_game_btn : Button = $VBoxContainer/Exit/Button

@onready var title_overlay: CanvasLayer = $TitleOverlay

func _ready() -> void:
	#start_game_solo_btn.grab_focus()
	start_game_solo_btn.button_up.connect(on_solo_start_pressed)
	start_game_2p_btn.button_up.connect(on_2p_start_pressed)
	exit_game_btn.button_up.connect(on_exit_pressed)
	
	title_overlay.visibility_changed.connect(on_title_visibility_changed)

func on_title_visibility_changed():
	if title_overlay.visible: return
	remove_title_overlay()

func remove_title_overlay():
	title_overlay.visibility_changed.disconnect(on_title_visibility_changed)
	title_overlay.queue_free()
	title_overlay = null
	start_game_solo_btn.grab_focus()

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
