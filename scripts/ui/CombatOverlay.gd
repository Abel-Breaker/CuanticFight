extends CanvasLayer

@onready var player1_healthbar_cover : ColorRect = $Player1/Covering
@onready var player2_healthbar_cover: ColorRect = $Player2/Covering

@onready var p2_name_label: Label = $Player2/Name

@export var healthbar_tween_time : float
@export var tween_transition_type : Tween.TransitionType

var player1_tween : Tween
var player2_tween : Tween

func _ready() -> void:
	
	call_deferred("init_healthbars")

func init_healthbars():
	player1_healthbar_cover.scale = Vector2(0,1)
	player2_healthbar_cover.scale = Vector2(0,1)

func setup(solo: bool):
	if solo:
		p2_name_label.text = "AI PLAYER"
	else:
		p2_name_label.text = "PLAYER 2"

func update_player_healthbar(player_num: int, remaining_health_percetange_0to1: float):
	var healthbar : ColorRect
	var tween : Tween
	if player_num == 1:
		healthbar = player1_healthbar_cover
		tween = player1_tween
	else:
		healthbar = player2_healthbar_cover
		tween = player2_tween

	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(healthbar, "scale:x", 1 - remaining_health_percetange_0to1, healthbar_tween_time).set_trans(tween_transition_type)


#func _exit_tree() -> void:
	#update_player_health.disconnect(on_update_player_health)
