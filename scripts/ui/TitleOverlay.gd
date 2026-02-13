extends CanvasLayer

@onready var start_btn: Button = $Start
@onready var title: TextureRect = $Title

@export var animation_time: float = 2
@export var transition_type: Tween.TransitionType
@export var final_btn_pos: Vector2 = Vector2(112., 258.)
@export var final_title_pos: Vector2 = Vector2(171.0, 63.)

var btn_tween: Tween = create_tween()
var title_tween: Tween = create_tween()

var tween_ended: bool = false

func _input(event):
	if tween_ended: return
	
	if event.is_action_pressed("ui_accept"):
		#print("#DEBUG: IN A RUSH")
		on_tween_end(0.25)

func _ready() -> void:
	start_btn.button_up.connect(on_user_interaction)
	start_btn.position = final_btn_pos + Vector2(0, 200)
	title.position = final_title_pos + Vector2(0, -300)
	
	play_move_tween(btn_tween, start_btn, final_btn_pos)
	play_move_tween(title_tween, title, final_title_pos)

func on_user_interaction():
	visible = false

func on_tween_end(focus_delay: float):
	if tween_ended: return
	if btn_tween and btn_tween.is_running():
		#print("#DEBUG: KILLING BUTTON")
		btn_tween.kill()
		start_btn.position = final_btn_pos
	if title_tween and title_tween.is_running():
		#print("#DEBUG: KILLING TITLE")
		title_tween.kill()
		title.position = final_title_pos
	
	tween_ended = true
	if focus_delay > 0:
		await get_tree().create_timer(focus_delay).timeout
	start_btn.disabled = false
	
	start_btn.grab_focus()

func play_move_tween(tween: Tween, obj: Control, target_pos: Vector2):
	tween.tween_property(obj, "position", target_pos, animation_time).set_trans(transition_type).finished.connect(on_tween_end.bind(0), CONNECT_ONE_SHOT)


func _exit_tree() -> void:
	start_btn.button_up.disconnect(on_user_interaction)
	if btn_tween and btn_tween.finished.is_connected(on_tween_end):
		btn_tween.finished.disconnect(on_tween_end)
	if title_tween and title_tween.finished.is_connected(on_tween_end):
		title_tween.finished.disconnect(on_tween_end)
