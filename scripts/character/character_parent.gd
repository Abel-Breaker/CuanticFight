extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@export var charID : int = 1

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump_"+str(charID)) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left_"+str(charID), "move_right_"+str(charID))
	
	if direction:
		print(direction)
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
