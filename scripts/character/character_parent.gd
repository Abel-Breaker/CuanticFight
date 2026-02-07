extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@export var charID : int = 1

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var lightAttackArea :  Area2D = $light_attack_area

# Priority table
const ANIM_PRIORITY := {
	"idle": 10,
	"run": 10,
	"falling": 20,
	"jump": 30,
	"land": 30,
	"hit": 60,
	"light_attack": 60,
	"ranged_attack": 60,
	"especial_attack": 60,
	"death": 100
}

# Animations that must finish once started
const LOCKING_ANIMS := {
	"hit": true,
	"death": true
}

var anim_locked := false
var locked_anim := ""
var current_priority := 0


func func_exit_tree() -> void:
	if sprite.animation_finished.is_connected(_on_anim_finished):
		sprite.animation_finished.disconnect(_on_anim_finished)
	if lightAttackArea.area_entered.is_connected(deal_light_attack_damage):
		lightAttackArea.area_entered.disconnect(deal_light_attack_damage)

func _ready() -> void:
	sprite.animation_finished.connect(_on_anim_finished)
	lightAttackArea.area_entered.connect(deal_light_attack_damage)

	
func deal_light_attack_damage(area: Area2D):
	print("the parent is " + str(area.get_parent()))

func _physics_process(delta: float) -> void:
	
	evaluate_base_animation()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if sprite.animation == "falling":
			request_anim("land")
	
	# Handle jump.
	if Input.is_action_just_pressed("jump_"+str(charID)) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		request_anim("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left_"+str(charID), "move_right_"+str(charID))
	
	if direction:
		print(request_anim("run"))
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.set_flip_h(false)
		else:
			sprite.set_flip_h(true)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_just_pressed("light_attack_"+str(charID)):
		request_anim("light_attack")
		lightAttackArea.monitoring = true
		
		lightAttackArea.monitoring = false
		
	move_and_slide()
	
# Should call this instead of play(...)
func request_anim(name: String) -> bool:
	var new_pri : int = ANIM_PRIORITY.get(name, 0)

	# If we're locked, only allow the same anim to keep playing
	if anim_locked and name != locked_anim:
		return false

	# If current animation has higher priority, deny
	if sprite.is_playing() and new_pri < current_priority and name != sprite.animation:
		return false

	# Avoid restarting the same animation
	if sprite.animation == name and sprite.is_playing():
		return true

	# Play and update state
	sprite.play(name)
	current_priority = new_pri

	# Lock if needed
	if LOCKING_ANIMS.get(name, false):
		anim_locked = true
		locked_anim = name
	return true
	
func _on_anim_finished():
	# Unlock when a locking anim finishes
	if anim_locked and sprite.animation == locked_anim:
		anim_locked = false
		locked_anim = ""
		current_priority = 0  # allow re-evaluation
		
	evaluate_base_animation()
	
	
# Locomotion chooser
func evaluate_base_animation():
	if anim_locked:
		return
	if not is_on_floor():
		request_anim("falling")
	elif abs(velocity.x) > 5:
		request_anim("run")
	else:
		request_anim("idle")
