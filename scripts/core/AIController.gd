extends Node

enum E_Mood {ESCAPING, HUNTING}

@onready var starting_timer: Timer = $StartingTime

var enemy : CharacterParent
var controlledCharacter : CharacterParent

var mood : E_Mood = E_Mood.HUNTING
var time_since_last_jump : float = 0


var time_since_last_action : float = 0

var isSetUp = false

func _ready() -> void:
	starting_timer.timeout.connect(func():
		isSetUp = true
	, CONNECT_ONE_SHOT)

func setup(inEnemy : CharacterParent, inControlledCharacter : CharacterParent) -> void:
	enemy = inEnemy
	controlledCharacter = inControlledCharacter
	starting_timer.start()



func _physics_process(delta: float) -> void:
	if 0.2 < time_since_last_action:
		time_since_last_action = 0
	else:
		time_since_last_action += delta
		return
	
	if not isSetUp:
		return
	if not controlledCharacter or not is_instance_valid(controlledCharacter): return

	#if controlledCharacter.current_health < controlledCharacter.MAX_HEALTH*0.3:
		#mood = E_Mood.ESCAPING
	elif mood != E_Mood.ESCAPING and enemy.current_health < enemy.MAX_HEALTH*0.5:
		mood = E_Mood.HUNTING
	if randf() < time_since_last_jump:
		jump()
		time_since_last_jump = 0
	else:
		time_since_last_jump += delta
	match mood:
		# Prioritizes surviving
		#E_Mood.ESCAPING:
			#move_away_from_enemy()
			#if randf() < 0.1:
				#use_ranged_attack()
		# Prioritizes dealing damage
		E_Mood.HUNTING:
			if randf() < 0.5:
				use_ranged_attack()
			if randf() < 0.2:
				use_especial_attack()
			if im_in_melee_range():
				use_light_attack()
			move_towards_enemy()


func im_in_melee_range() -> bool:
	return true if abs(controlledCharacter.get_position().x - enemy.get_position().x) <= 21 else false

func im_on_the_right() -> bool:
	return true if controlledCharacter.get_position().x - enemy.get_position().x > 0 else false

func look_away_from_enemy() -> void:
	if im_on_the_right():
		Input.action_press("move_right_2")
		Input.action_release("move_right_2")
	else:
		Input.action_press("move_left_2")
		Input.action_release("move_left_2")

func look_towards_enemy() -> void:
	if im_on_the_right():
		safe_random_yielding_input_pressing("move_left_2", 1)
	else:
		safe_random_yielding_input_pressing("move_right_2", 1)

func move_away_from_enemy() -> void:
	if im_on_the_right():
		safe_random_yielding_input_pressing("move_right_2")
	else:
		safe_random_yielding_input_pressing("move_left_2")

func move_towards_enemy() -> void:
	if im_on_the_right():
		safe_random_yielding_input_pressing("move_left_2")
	else:
		safe_random_yielding_input_pressing("move_right_2")


func safe_random_yielding_input_pressing(input_name: String, customTime : float = 0):
	var timer = get_tree().create_timer(randf()*4 if customTime==0 else customTime)
	timer.timeout.connect(func(): Input.action_release(input_name))
	Input.action_press(input_name)

func use_light_attack() -> void:
	Input.action_press("light_attack_2")
	Input.action_release("light_attack_2")
	look_towards_enemy()
	
	
	

func use_ranged_attack() -> void:
	Input.action_press("ranged_attack_2")
	Input.action_release("ranged_attack_2")
	look_towards_enemy()

func use_especial_attack() -> void:
	Input.action_press("especial_attack_2")
	Input.action_release("especial_attack_2")
	look_away_from_enemy()

func jump() -> void:
	Input.action_press("jump_2")
	Input.action_release("jump_2")

func _exit_tree() -> void:
	enemy = null
	controlledCharacter = null
