extends RigidBody2D

class_name Proyectile

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var impact_sprite: Sprite2D = $Impact

@onready var alive_timer: Timer = $AliveTime
@onready var destroy_anim_timer: Timer = $DestroyAnimTime

@export var alive_bullet_time: float = 3

var dealing_damage: int = 0
var owner_player_num: int = 0

func _ready() -> void:
	alive_timer.wait_time = alive_bullet_time
	alive_timer.timeout.connect(free_proyectile_resources, CONNECT_ONE_SHOT)
	destroy_anim_timer.timeout.connect(free_proyectile_resources, CONNECT_ONE_SHOT)
	alive_timer.start()
	
	body_entered.connect(proyectile_impacted)

func setup(owner_id: int, dmg: int, layer: int, mask: int):
	owner_player_num = owner_id
	self.collision_layer = layer
	self.collision_mask = mask
	dealing_damage = dmg

func proyectile_impacted(body: Node):
	if self.is_queued_for_deletion():
		return
	
	if not alive_timer.is_stopped():
		alive_timer.stop()
	
	animated_sprite.visible = false
	impact_sprite.visible = true
	set_deferred("freeze", true)
	
	destroy_anim_timer.start()

func free_proyectile_resources():
	self.queue_free()

func _exit_tree() -> void:
	if body_entered.is_connected(proyectile_impacted):
		body_entered.disconnect(proyectile_impacted)
	if alive_timer.timeout.is_connected(free_proyectile_resources):
		alive_timer.timeout.disconnect(free_proyectile_resources)
	if destroy_anim_timer.timeout.is_connected(free_proyectile_resources):
		destroy_anim_timer.timeout.disconnect(free_proyectile_resources)
