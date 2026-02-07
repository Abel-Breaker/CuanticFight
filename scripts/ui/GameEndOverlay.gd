extends Panel

@onready var replay_btn : Button = $Replay
@onready var main_menu_btn : Button = $MainMenu

@export var drop_time : float
@export var transition_type : Tween.TransitionType


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	replay_btn.button_up.connect(on_replay_pressed)
	main_menu_btn.button_up.connect(on_main_menu_pressed)
	
	call_deferred("tween_down")

func on_replay_pressed():
	SignalContainer.game_replay.emit()

func on_main_menu_pressed():
	SignalContainer.game_exit.emit()

func tween_down() -> void:
	var target_position = Vector2(position.x, position.y - size.y)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, drop_time).set_trans(transition_type)


func _exit_tree() -> void:
	replay_btn.button_up.disconnect(on_replay_pressed)
	main_menu_btn.button_up.disconnect(on_main_menu_pressed)
