extends CanvasLayer

@onready var panel : Panel = $Panel
@onready var text_label : Label = $Panel/Label
@onready var replay_btn : Button = $Panel/Replay
@onready var main_menu_btn : Button = $Panel/MainMenu

@export var drop_time : float
@export var transition_type : Tween.TransitionType


func _ready() -> void:

	replay_btn.button_up.connect(on_replay_pressed)
	main_menu_btn.button_up.connect(on_main_menu_pressed)
	
	call_deferred("tween_down")

func on_replay_pressed():
	SignalContainer.game_replay.emit()

func on_main_menu_pressed():
	SignalContainer.game_exit.emit()

func tween_down() -> void:
	var target_position = Vector2(panel.position.x, panel.position.y + panel.size.y)
	var tween = create_tween()
	tween.tween_property(panel, "position", target_position, drop_time).set_trans(transition_type)

func set_winner_text(winner_player: int, solo_game: bool):
	if winner_player == 1:
		text_label.text = "PLAYER 1 WINS!"
	else:
		if solo_game:
			text_label.text = "AI PLAYER WINS!"
		else:
			text_label.text = "PLAYER 2 WINS!"

func _exit_tree() -> void:
	replay_btn.button_up.disconnect(on_replay_pressed)
	main_menu_btn.button_up.disconnect(on_main_menu_pressed)
