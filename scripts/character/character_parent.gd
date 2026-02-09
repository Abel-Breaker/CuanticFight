extends CharacterBody2D

class_name CharacterParent

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const MAX_HEALTH = 100

@export var charID : int = 1

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var lightAttack : LightAttack = $LightAttack
@onready var rangedAttack : RangeAttack = $RangeAttack
@onready var especialAttack : EspecialAttack = $EspecialAttack

@onready var hurtbox : Area2D = $HurtBox

var desduplicadoFLAG : bool = false 

var isLookingLeft : bool

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
	"die": 100
}

# Animations that must finish once started
const LOCKING_ANIMS := {
	"hit": true,
	"die": true
}

var anim_locked := false
var locked_anim := ""
var current_priority := 0

var current_health := MAX_HEALTH




func _exit_tree() -> void:
	if sprite.animation_finished.is_connected(_on_anim_finished):
		sprite.animation_finished.disconnect(_on_anim_finished)
	if hurtbox.body_entered.is_connected(on_hurtbox_body_entered):
		hurtbox.body_entered.disconnect(on_hurtbox_body_entered)

func _ready() -> void:
	sprite.animation_finished.connect(_on_anim_finished)
	lightAttack.setup(self)
	rangedAttack.setup(self)
	especialAttack.setup(self)
	hurtbox.set_collision_layer(charID)
	hurtbox.collision_mask = charID << 2 #NOTE: Used for projectiles
	hurtbox.body_entered.connect(on_hurtbox_body_entered)
	isLookingLeft = sprite.flip_h
	
	if charID == 2:
		call_deferred("flip_player1_sprite_on_load")
	
func flip_player1_sprite_on_load():
	flip_character(true)

func on_hurtbox_body_entered(body: Node2D):
	if not body is RigidBody2D: return

	var dmg : int = body.get_meta("DMG")

	received_damage(dmg)
	body.queue_free()

func received_damage(damage_amount : int):
	if especialAttack.end_duplication_character():
		#print("PLAYER" +str(charID)+ ": received "+str(damage_amount)+" damage")
		current_health -= damage_amount
		if current_health <= 0:
			current_health = 0 
			request_anim("die")
		else:
			request_anim("hit")
		SignalContainer.player_received_damage.emit(charID, current_health, MAX_HEALTH)

func _physics_process(delta: float) -> void:
	if current_health <= 0: return
	
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
		velocity.x = direction * SPEED
		if direction > 0:
			if isLookingLeft:
				flip_character(false)
		else:
			if not isLookingLeft:
				flip_character(true)
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("light_attack_"+str(charID)):
		if especialAttack.end_duplication_character():
			if lightAttack.try_to_use():
				request_anim("light_attack")
				
	if Input.is_action_just_pressed("ranged_attack_"+str(charID)):
		if especialAttack.end_duplication_character():
			if request_anim("ranged_attack"):
				rangedAttack.try_to_use()
		
	if Input.is_action_just_pressed("especial_attack_"+str(charID)):
		if especialAttack.try_to_use():
			request_anim("especial_attack")
		
		
	move_and_slide()
	
# Should call this instead of play(...)
func request_anim(animName: String) -> bool:
	var new_pri : int = ANIM_PRIORITY.get(animName, 0)

	# If we're locked, only allow the same anim to keep playing
	if anim_locked and animName != locked_anim:
		return false

	# If current animation has higher priority, deny
	if sprite.is_playing() and new_pri < current_priority and animName != sprite.animation:
		return false

	# Avoid restarting the same animation
	if sprite.animation == animName and sprite.is_playing():
		return true

	# Play and update state
	sprite.play(animName)
	current_priority = new_pri

	# Lock if needed
	if LOCKING_ANIMS.get(name, false):
		anim_locked = true
		locked_anim = name
	return true
	
func _on_anim_finished():
	# Unlock when a locking anim finishes
	if anim_locked and sprite.animation == locked_anim:
		if current_priority < ANIM_PRIORITY.get("die"): # when dead cannot change animation
			anim_locked = false
			locked_anim = ""
			current_priority = 0  # allow re-evaluation
		
	evaluate_base_animation()
	
	
# Locomotion chooser
func evaluate_base_animation():
	if anim_locked or current_health <= 0:
		return
	if not is_on_floor():
		request_anim("falling")
	elif abs(velocity.x) > 5:
		request_anim("run")
	else:
		request_anim("idle")
		
		
func flip_character(lookLeft:bool) ->void:
	isLookingLeft = lookLeft
	#print("DEBUG: Changed looking dir: lookLeft = " + str(lookLeft))
	if lookLeft:
		SignalContainer.player_changed_looking_direction.emit(charID, -1)
		sprite.set_flip_h(true)
		lightAttack.set_position(Vector2(-lightAttack.position.x, lightAttack.position.y))
	else: 
		SignalContainer.player_changed_looking_direction.emit(charID, 1)
		sprite.set_flip_h(false)
		lightAttack.set_position(Vector2(-lightAttack.position.x, lightAttack.position.y))
