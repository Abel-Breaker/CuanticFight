extends Node

enum DecisionState {ESCAPE, CATCH, ATTACK_MIDRANGE, ATTACK_CLOSERANGE}

@onready var starting_timer: Timer = $StartingTime
@onready var decision_timer: Timer = $DecisionTimer
@onready var can_do_action_timer: Timer = $CanDoActionTimer
@onready var move_timer: Timer = $MoveTimer
@onready var collide_front_raycast: RayCast2D = $CollideInFront

@export var far_distance: float = 300
@export var near_distance: float = 60
@export var view_distance_to_jump: float = 60

var enemy : CharacterParent
var myCharacter : CharacterParent

var mood : DecisionState = DecisionState.ATTACK_MIDRANGE
#var time_since_last_jump : float = 0
var end_movement_to_left_int: int = 0
var can_make_action: bool = true

var isSetUp = false

func _ready() -> void:
	starting_timer.timeout.connect(func():
		isSetUp = true
		decision_timer.start()
		think_next_decision_state()
	, CONNECT_ONE_SHOT)
	decision_timer.timeout.connect(think_next_decision_state)
	can_do_action_timer.timeout.connect(allow_actions)

func setup(inEnemy : CharacterParent, inControlledCharacter : CharacterParent) -> void:
	enemy = inEnemy
	myCharacter = inControlledCharacter
	starting_timer.start()

func allow_actions():
	can_make_action = true

func think_next_decision_state():
	if not myCharacter or not is_instance_valid(myCharacter): return
	
	var dx = enemy.global_position.x - myCharacter.global_position.x
	var enemy_vel = enemy.velocity
	var distance = abs(dx)
	if distance > far_distance and randf() < 0.8:
		mood = DecisionState.CATCH
	elif distance <= near_distance:
		mood = DecisionState.ATTACK_CLOSERANGE
	#elif ((dx > 0 and enemy_vel.x > 0) or (dx < 0 and enemy_vel.x < 0)) \
	#	and enemy.current_health <= myCharacter.current_health:
	#	
	#	mood = DecisionState.HUNTING
	#elif (myCharacter.current_health < enemy.current_health * 0.5):
	#	mood = DecisionState.ESCAPING
	else:
		mood = DecisionState.ATTACK_MIDRANGE
		
	print("DEBUG: MOOD: " + str(mood) + " (ESCAPING, HUNTING, COMBO, TESTING) | ENEMYPOS: " + str(enemy.global_position) + ", MYPOS: " + str(myCharacter.global_position))
	


func _physics_process(delta: float) -> void:
	if not isSetUp or not can_make_action:
		return
	if not myCharacter or not is_instance_valid(myCharacter): return
	
	end_movement_to_left_int = 0
	can_make_action = false
	can_do_action_timer.start()
	
	match mood:
		# Prioritizes surviving
		DecisionState.ESCAPE:
			end_movement_to_left_int += move_away_from_enemy(0.4, 0.4)
			if randf() < 0.15:
				look_towards_enemy()
				use_ranged_attack()
		# Prioritizes dealing damage
		DecisionState.CATCH:
			end_movement_to_left_int += move_towards_enemy(0.3, 0.5)
			if randf() < 0.2:
				look_towards_enemy()
				use_ranged_attack()
		# Balanced between dealing damage and surviving
		DecisionState.ATTACK_MIDRANGE:
			if randf() < 0.15:
				jump()
			if randf() < 0.3:
				use_ranged_attack()
			end_movement_to_left_int += move_towards_enemy(0.225, 0.5)
		DecisionState.ATTACK_CLOSERANGE:
			if randf() < 0.1:
				jump()
			elif enemy.global_position.y > (myCharacter.global_position.y + 5) and randf() < 0.3:
				jump()
			use_light_attack()
			end_movement_to_left_int += move_towards_enemy(0.125, 0.285)
		
	#NOTE: Raycast to jump
	if end_movement_to_left_int != 0:
		collide_front_raycast.global_position = myCharacter.global_position
		collide_front_raycast.target_position = Vector2((-1 if end_movement_to_left_int < 0 else 1) * view_distance_to_jump, 0)
		collide_front_raycast.collide_with_bodies = true
		collide_front_raycast.force_raycast_update()
		if collide_front_raycast.is_colliding():
			jump()
		#-----------
		"""
		var line = Line2D.new()
		line.add_point(collide_front_raycast.global_position)
		line.add_point(collide_front_raycast.global_position + collide_front_raycast.target_position)
		line.width = 2
		line.default_color = Color.YELLOW
		get_tree().root.add_child(line)
		var line2 = Line2D.new()
		line2.add_point(collide_front_raycast.global_position)
		line2.add_point(collide_front_raycast.global_position + Vector2(4,0))
		line2.width = 2
		line2.default_color = Color.RED
		get_tree().root.add_child(line2)
		"""
		#-----------


#func im_in_melee_range() -> bool:
#	return true if abs(myCharacter.get_position().x - enemy.get_position().x) <= 21 else false

func im_on_the_right() -> bool:
	return true if myCharacter.get_position().x - enemy.get_position().x > 0 else false

func look_away_from_enemy() -> void:
	if im_on_the_right():
		Input.action_press("move_right_1")
		Input.action_release("move_right_1")
	else:
		Input.action_press("move_left_1")
		Input.action_release("move_left_1")

func look_towards_enemy() -> void:
	if im_on_the_right():
		var running_right = Input.is_action_pressed("move_right_1")
		if running_right:
			Input.action_release("move_right_1")
		Input.action_press("move_left_1")
		Input.action_release("move_left_1")
		if running_right:
			Input.action_press("move_right_1")
	else:
		var running_left = Input.is_action_pressed("move_left_1")
		if running_left:
			Input.action_release("move_left_1")
		Input.action_press("move_right_1")
		Input.action_release("move_right_1")
		if running_left:
			Input.action_press("move_left_1")

func move_away_from_enemy(min: float, max: float) -> int:
	if im_on_the_right():
		safe_random_yielding_input_pressing("move_right_1", min, max)
		return 1
	else:
		safe_random_yielding_input_pressing("move_left_1", min, max)
		return -1

func move_towards_enemy(min: float, max: float) -> int:
	if im_on_the_right():
		safe_random_yielding_input_pressing("move_left_1", min, max)
		return -1
	else:
		safe_random_yielding_input_pressing("move_right_1", min, max)
		return 1

func on_move_timer_end(input_name: String):
	Input.action_release(input_name)

func safe_random_yielding_input_pressing(input_name: String, min: float, max: float):
	if not move_timer.is_stopped():
		move_timer.stop()
		move_timer.timeout.emit()
	move_timer.wait_time = randf_range(min, max)
	move_timer.timeout.connect(on_move_timer_end.bind(input_name), CONNECT_ONE_SHOT)
	move_timer.start()
	Input.action_press(input_name)

func use_light_attack() -> void:
	Input.action_press("light_attack_1")
	Input.action_release("light_attack_1")

func use_ranged_attack() -> void:
	Input.action_press("ranged_attack_1")
	Input.action_release("ranged_attack_1")

func use_especial_attack() -> void:
	Input.action_press("especial_attack_1")
	Input.action_release("especial_attack_1")

func jump() -> void:
	Input.action_press("jump_1")
	Input.action_release("jump_1")

func _exit_tree() -> void:
	decision_timer.timeout.disconnect(think_next_decision_state)
	can_do_action_timer.timeout.disconnect(allow_actions)
	enemy = null
	myCharacter = null
