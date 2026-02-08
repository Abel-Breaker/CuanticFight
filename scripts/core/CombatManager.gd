extends Node

@onready var combat_overlay : CanvasLayer = $CombatOverlay
@onready var player1 : CharacterBody2D = $Player1
@onready var player2 : CharacterBody2D = $Player2

var combat_ended : bool = false

func _ready() -> void:
	SignalContainer.player_received_damage.connect(player_received_dmg)

func player_received_dmg(player_num: int, remaining_health: int, total_health: int):
	var remaining_health_percentage: float = float(remaining_health) / float(total_health)
	combat_overlay.update_player_healthbar(player_num, remaining_health_percentage)
	if remaining_health == 0:
		combat_ended = true
		SignalContainer.game_finish.emit(player_num%2 +1) #Sends the winner player (2 if 1 has 0 health and the other way around)

func get_players() -> Array[CharacterBody2D]:
	return [player1, player2]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not combat_ended:
			SignalContainer.game_pause.emit()
		else:
			SignalContainer.game_exit.emit() #TODO: Change (only debug because viewport can't be seen right now)


func _exit_tree() -> void:
	SignalContainer.player_received_damage.disconnect(player_received_dmg)
