extends Node
class_name CombatManager

@onready var ai_scene1 = preload("res://scenes/core/AIController.tscn")
#@onready var ai_scene2 = preload("res://scenes/core/AIController_2.tscn")

@onready var quant_player_scene = preload("res://scenes/characters/CharacterParent.tscn")
@onready var classic_player_scene = preload("res://scenes/characters/ClassicCharacter.tscn")

@onready var combat_overlay : CanvasLayer = $CombatOverlay
@onready var camera_system = $CameraSystem
@onready var spawn1 = $Spawn1
@onready var spawn2 = $Spawn2

var ai_system1: Node
#var ai_system2: Node

var player1_characters: Array[CharacterParent] = []
var player2_characters: Array[CharacterParent] = []

var player_look_direction: Array[int] = [1, -1] #Player1 starts looking right and Player2 left

var combat_ended : bool = false

func _ready() -> void:
	SignalContainer.player_received_damage.connect(player_received_dmg)
	SignalContainer.player_changed_looking_direction.connect(player_changed_looking_direction)
	SignalContainer.player_duplicated_himself.connect(player_duplicated_himself)
	SignalContainer.player_determined_himself.connect(player_determined_himself)
	#call_deferred("setup")

func setup(char_type_player1: ProyectilesManager.ProyectileType, char_type_player2: ProyectilesManager.ProyectileType, ai_game: bool):
	var char1: CharacterParent
	var char2: CharacterParent
	if char_type_player1 == ProyectilesManager.ProyectileType.QUANTIC:
		char1 = quant_player_scene.instantiate()
	else:
		char1 = classic_player_scene.instantiate()
	if char_type_player2 == ProyectilesManager.ProyectileType.QUANTIC:
		char2 = quant_player_scene.instantiate()
	else:
		char2 = classic_player_scene.instantiate()
	
	char1.global_position = spawn1.global_position
	char2.global_position = spawn2.global_position
	char1.charID = 1
	char1.player_type = char_type_player1
	char2.player_type = char_type_player2
	char2.charID = 2
	get_tree().root.add_child(char1)
	get_tree().root.add_child(char2)
	player1_characters.append(char1)
	player2_characters.append(char2)
	if ai_game:
		ai_system1 = ai_scene1.instantiate()
		get_tree().root.add_child(ai_system1)
		ai_system1.setup(char1, char2)
		#ai_system2 = ai_scene1.instantiate()
		#get_tree().root.add_child(ai_system2)
		#ai_system2.setup(char1, char2)
	camera_system.enable_camera_updates(true)
	
	#player1_characters.append($Player1)
	#player2_characters.append($Player2)
	#camera_system.enable_camera_updates(true)
	#var ai = ai_scene.instantiate()
	#get_tree().root.add_child(ai)
	#ai.setup(player1_characters[0], player2_characters[0])

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
	var updated_characters: Array[CharacterParent] = []
	for i in range(all_player_characters.size()):
		var character: CharacterParent = all_player_characters[i]
		if character.charID == player_num and not character.is_queued_for_deletion():
			updated_characters.append(character)
	if player_num == 1:
		player1_characters = updated_characters
	else:
		player2_characters = updated_characters
	#print("PLAYER"+str(player_num)+" characters: "+str(updated_characters))

func is_enemy_looking_at_me(my_id: int) -> bool:
	var caller_player: CharacterParent
	var enemy_player: CharacterParent
	if player1_characters.size() == 0 or player2_characters.size() == 0: return true
	
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



func get_players() -> Array[CharacterParent]:
	var retArray : Array[CharacterParent] = []
	#print("DEBUG: SIZE1: "+str(player1_characters.size()))
	var p1_size = player1_characters.size()
	if p1_size == 1:
		retArray.append(player1_characters[0])
		retArray.append(null)
	elif p1_size == 2:
		retArray.append(player1_characters[0])
		retArray.append(player1_characters[1])
		
	var p2_size = player2_characters.size()
	if p2_size == 1:
		retArray.append(player2_characters[0])
		retArray.append(null)
	elif p2_size == 2:
		retArray.append(player2_characters[0])
		retArray.append(player2_characters[1])
	#print("CHARACTERS: " +str(retArray))
	return retArray

func player_exists(p: CharacterParent) -> bool:
	return p != null and is_instance_valid(p)

func _process(delta: float) -> void:
	if not combat_ended and Input.is_action_just_pressed("pause"):
		SignalContainer.game_pause.emit()


func _exit_tree() -> void:
	SignalContainer.player_received_damage.disconnect(player_received_dmg)
	SignalContainer.player_changed_looking_direction.disconnect(player_changed_looking_direction)
	SignalContainer.player_duplicated_himself.disconnect(player_duplicated_himself)
	SignalContainer.player_determined_himself.disconnect(player_determined_himself)
	print("DEBUG: Exiting CombatManager")
	if ai_system1:
		print("DEBUG: Freeing AI")
		ai_system1.queue_free()
		ai_system1 = null
	#if ai_system2:
	#	print("DEBUG: Freeing AI")
	#	ai_system2.queue_free()
	#	ai_system2 = null
	for i in range(player1_characters.size()):
		player1_characters[i].queue_free()
	for i in range(player2_characters.size()):
		player2_characters[i].queue_free()
