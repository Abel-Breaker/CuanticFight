extends CanvasLayer

@onready var player1_healthbar : ColorRect = $Player1/HealthBar
@onready var player2_healthbar : ColorRect = $Player2/HealthBar

#signal update_player_health(player_num : int, remaining_health_percentage_0to1 : float)
@export var healthbar_tween_time : float
@export var tween_transition_type : Tween.TransitionType

var player1_tween : Tween
var player2_tween : Tween

func _ready() -> void:
	
	#update_player_health.connect(on_update_player_health)
	call_deferred("init_healthbars")

func init_healthbars():
	player1_healthbar.scale = Vector2(1,1)
	player2_healthbar.scale = Vector2(1,1)

func update_player_healthbar(player_num: int, remaining_health_percetange_0to1: float):
	var healthbar : ColorRect
	var tween : Tween
	if player_num == 1:
		healthbar = player1_healthbar
		tween = player1_tween
	else:
		healthbar = player2_healthbar
		tween = player2_tween

	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(healthbar, "scale:x", remaining_health_percetange_0to1, healthbar_tween_time).set_trans(tween_transition_type)


#func _exit_tree() -> void:
	#update_player_health.disconnect(on_update_player_health)
