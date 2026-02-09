extends Node
class_name CombatManager

@onready var combat_overlay : CanvasLayer = $CombatOverlay
@onready var player1 : CharacterParent = $Player1
@onready var player2 : CharacterParent = $Player2

var player1_characters: Array[CharacterParent]
var player2_characters: Array[CharacterParent]

var player_look_direction: Array[int] = [1, -1] #Player1 starts looking right and Player2 left

var combat_ended : bool = false

func _ready() -> void:
	SignalContainer.player_received_damage.connect(player_received_dmg)
	SignalContainer.player_changed_looking_direction.connect(player_changed_looking_direction)
	SignalContainer.player_duplicated_himself.connect(player_duplicated_himself)
	SignalContainer.player_determined_himself.connect(player_determined_himself)
	call_deferred("setup")

func setup():
	player1_characters[0] = $Player1
	player2_characters[0] = $Player2

func player_received_dmg(player_num: int, remaining_health: int, total_health: int):
	var remaining_health_percentage: float = float(remaining_health) / float(total_health)
	combat_overlay.update_player_healthbar(player_num, remaining_health_percentage)
	AudioManager.on_player_low_health(player_num, remaining_health_percentage)
	if remaining_health == 0:
		combat_ended = true
		SignalContainer.game_finish.emit(player_num%2 +1) #Sends the winner player (2 if 1 has 0 health and the other way around)

func player_changed_looking_direction(player_num: int, new_direction: int):
	#print("DEBUG: Changing looking for index: " + str(player_num -1) + " to value: " + str(new_direction))
	player_look_direction[player_num -1] = new_direction

func player_duplicated_himself(player_num: int):
	update_my_characters(player_num)

func player_determined_himself(player_num: int):
	update_my_characters(player_num)

func update_my_characters(player_num: int):
	var all_player_characters = get_tree().get_nodes_in_group("Players")
	var this_player_characters: Array[CharacterParent] = player1_characters
	if player_num == 2:
		this_player_characters = player2_characters
	
	var updated_characters: Array[CharacterParent] = []
	for i in range(all_player_characters.size()):
		var character: CharacterParent = all_player_characters[i]
		if character.charID == player_num:
			updated_characters[updated_characters.size()] = character
	
	this_player_characters = updated_characters

func is_enemy_looking_at_me(my_id: int) -> bool:
	var caller_player: CharacterParent
	var enemy_player: CharacterParent
	if my_id == 1:
		caller_player = player1_characters[0] #player1
		enemy_player = player2_characters[0] #player2
	else:
		caller_player = player2_characters[0] #player2
		enemy_player = player1_characters[0] #player1
	
	var i_am_left_of_him =  caller_player.global_position.x < enemy_player.global_position.x
	var enemy_look_dir: int = player_look_direction[my_id %2]
	
	#NOTE: This represents that the enemy is looking at me
	var looking_at_me: bool = false
	if i_am_left_of_him and (enemy_look_dir == -1):
		looking_at_me = true 
	elif not i_am_left_of_him and (enemy_look_dir == 1):
		looking_at_me = true
	
	return looking_at_me

func get_enemy_player(my_id: int) -> Array[CharacterParent]:
	if my_id == 1:
		return player2_characters
	return player1_characters


# TODO: When dividing cuantic player return 3 players
func get_players(): #Array[Array[CharacterParent]]:
	return [player1_characters, player2_characters]

func _process(delta: float) -> void:
	if not combat_ended and Input.is_action_just_pressed("pause"):
		SignalContainer.game_pause.emit()


func _exit_tree() -> void:
	SignalContainer.player_received_damage.disconnect(player_received_dmg)
	SignalContainer.player_changed_looking_direction.disconnect(player_changed_looking_direction)
	SignalContainer.player_duplicated_himself.disconnect(player_duplicated_himself)
	SignalContainer.player_determined_himself.disconnect(player_determined_himself)
