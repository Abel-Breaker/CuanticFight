extends Node2D

@onready var black_hole_scene: Resource = preload("res://scenes/vfx/BlackHole.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var effect_timer: Timer = $EffectTimer
@onready var ray_cast: RayCast2D = $RayCast

@export var attracting_radius: float = 200.
@export var attracting_force: float = 300.

var character : CharacterParent
var canBeUsed : bool = true
var curr_black_hole : AnimatedSprite2D = null

func _ready() -> void:
	cooldown.timeout.connect(on_cooldown_ended)
	effect_timer.timeout.connect(on_effect_ended)

func on_cooldown_ended():
	canBeUsed = true

func on_effect_ended():
	if curr_black_hole:
		curr_black_hole.queue_free()

func setup(inCharacter: CharacterParent) -> void:
	character = inCharacter


func try_to_use() -> bool:
	if not canBeUsed: return false
	
	var combat_manager = GameManager.get_combat_manager()
	if not combat_manager: return false
	
	canBeUsed = false
	cooldown.start()
	effect_timer.start()
	
	var enemy_character: CharacterParent = combat_manager.get_enemy_player(character.charID)
	var enemy_pos: Vector2 = enemy_character.global_position
	var moving_dir: Vector2 = character.velocity.normalized()
	
	var vfx_spawn_point = enemy_pos + moving_dir * attracting_force
	#var force_to_apply #TODO: Scale force with distance to target point
	
	ray_cast.global_position = enemy_pos
	ray_cast.target_position = vfx_spawn_point
	
	ray_cast.collide_with_bodies = true
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		vfx_spawn_point = collision_point
	curr_black_hole = black_hole_scene.instantiate()
	curr_black_hole.global_position = vfx_spawn_point
	curr_black_hole.visible = true
	get_tree().root.add_child(curr_black_hole)
	enemy_character.velocity += moving_dir * attracting_force 
	
	return true

func _exit_tree() -> void:
	cooldown.timeout.disconnect(on_cooldown_ended)
	effect_timer.timeout.disconnect(on_effect_ended)

func end_duplication_character() -> bool:
	return true
