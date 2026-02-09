extends Node2D

@onready var black_hole_scene: Resource = preload("res://scenes/vfx/BlackHole.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var effect_timer: Timer = $EffectTimer
@onready var ray_cast: RayCast2D = $RayCast

@export var spawn_distance_from_enemy = 150.
@export var attracting_radius: float = 400.
@export var max_attracting_force: float = 1500.
#@export var force_decay: float = 0.95

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
		curr_black_hole = null
	var combat_manager = GameManager.get_combat_manager()
	if not combat_manager: return
	
	var enemy_character: CharacterParent = combat_manager.get_enemy_player(character.charID)
	enemy_character.deactivate_others_forces()

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
	
	var vfx_spawn_point = moving_dir * spawn_distance_from_enemy
	
	ray_cast.global_position = enemy_pos
	ray_cast.target_position = vfx_spawn_point
	ray_cast.collide_with_bodies = true
	ray_cast.force_raycast_update()
	
	curr_black_hole = black_hole_scene.instantiate()
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		curr_black_hole.global_position = collision_point
	else:
		curr_black_hole.global_position = vfx_spawn_point + enemy_pos

	curr_black_hole.visible = true
	enemy_character.allow_others_to_apply_force_to_me()
	get_tree().root.add_child(curr_black_hole)
	
	"""
	var line = Line2D.new()
	line.add_point(ray_cast.global_position)
	line.add_point(ray_cast.global_position + ray_cast.target_position)
	line.width = 2
	line.default_color = Color.YELLOW
	get_tree().root.add_child(line)
	var line2 = Line2D.new()
	line2.add_point(ray_cast.global_position)
	line2.add_point(ray_cast.global_position + Vector2(4,0))
	line2.width = 2
	line2.default_color = Color.RED
	get_tree().root.add_child(line2)
	"""
	return true

#NOTE: Used to update the velocity applied to the enemy by the current black hole
func _physics_process(delta: float) -> void:
	if not curr_black_hole: return
	var combat_manager = GameManager.get_combat_manager()
	if not combat_manager: return
	
	var enemy_character: CharacterParent = combat_manager.get_enemy_player(character.charID)
	var enemy_pos: Vector2 = enemy_character.global_position
	
	var diff_vector = curr_black_hole.global_position - enemy_pos
	var distance = (diff_vector).length()
	var force_direction = (diff_vector).normalized()
	
	var force_modifier: float = ease(clamp((attracting_radius - distance) / attracting_radius, 0, 1), 0.2)
	var total_force: Vector2 = lerpf(0.0, max_attracting_force, force_modifier) * force_direction
	enemy_character.velocity += Vector2(total_force.x, 1.5*total_force.y) * delta
	#print(total_force)

func _exit_tree() -> void:
	cooldown.timeout.disconnect(on_cooldown_ended)
	effect_timer.timeout.disconnect(on_effect_ended)

func end_duplication_character() -> bool:
	return true
