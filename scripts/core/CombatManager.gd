extends Node
class_name CombatManager

@onready var combat_overlay : CanvasLayer = $CombatOverlay
@onready var player1 : CharacterParent = $Player1
@onready var player2 : CharacterParent = $Player2

var player_look_direction: Array[int] = [1, -1] #Player1 starts looking right and Player2 left
#TODO: From players, notify the change of direction
var combat_ended : bool = false

func _ready() -> void:
	SignalContainer.player_received_damage.connect(player_received_dmg)

func is_enemy_looking_at_me(my_id: int) -> bool:
	var caller_player: CharacterParent
	var enemy_player: CharacterParent
	if my_id == 1:
		caller_player = player1
		enemy_player = player2
	else:
		caller_player = player2
		enemy_player = player1
	
	var x_diff_vector = enemy_player.global_position.x - caller_player.global_position.x
	#NOTE: This represents that the enemy is looking at me
	return (x_diff_vector * player_look_direction[my_id -1]) >= 0 


func player_received_dmg(player_num: int, remaining_health: int, total_health: int):
	var remaining_health_percentage: float = float(remaining_health) / float(total_health)
	combat_overlay.update_player_healthbar(player_num, remaining_health_percentage)
	if remaining_health == 0:
		combat_ended = true
		SignalContainer.game_finish.emit(player_num%2 +1) #Sends the winner player (2 if 1 has 0 health and the other way around)

# TODO: When dividing cuantic player return 3 players
func get_players() -> Array[CharacterParent]:
	return [player1, player2]

func _process(delta: float) -> void:
	if not combat_ended and Input.is_action_just_pressed("pause"):
		SignalContainer.game_pause.emit()


func _exit_tree() -> void:
	SignalContainer.player_received_damage.disconnect(player_received_dmg)
