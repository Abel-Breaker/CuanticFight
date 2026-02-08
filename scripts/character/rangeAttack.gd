extends Node2D

class_name RangeAttack

var character: CharacterParent

@onready var cooldown : Timer = $Cooldown
@onready var shoot_position : Marker2D = $Marker2D

@export var single_bullet_speed: float = 500
@export var multi_bullet_speed: float = 300

var canBeUsed : bool = true
var collision_layer: int
var collision_mask: int

func _ready() -> void:
	cooldown.timeout.connect(updateUsability)



func setup(inCharacter: CharacterParent) -> void:
	character = inCharacter

	if character.charID == 1: #TODO: Make it collide with the environment only
		collision_mask = 0
		collision_layer = 4
	else:
		collision_mask = 0
		collision_layer = 8


func updateUsability():
	canBeUsed = true

func _exit_tree() -> void:
	if cooldown.timeout.is_connected(updateUsability):
		cooldown.timeout.disconnect(updateUsability)


# Returns true if succesfully used and false if cannot use for any reason
func try_to_use() -> bool:
	if not canBeUsed: return false
	
	var combat_manager = GameManager.get_combat_manager()
	if not combat_manager: return false
	var enemy_is_looking_at_me = combat_manager.is_enemy_looking_at_me(character.charID)
	
	var look_dir_modifier: int = -1 if character.isLookingLeft else 1
	
	canBeUsed = false
	cooldown.start()
	
	if enemy_is_looking_at_me: #Shooting like a physical particle
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position, 
			Vector2(look_dir_modifier * single_bullet_speed,0),
			collision_layer,
			collision_mask,
			0
		)
		
	else: #Shooting like a wave
		var x_axis_speed: float = look_dir_modifier * multi_bullet_speed
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(x_axis_speed, -20),
			collision_layer,
			collision_mask,
			0
		)
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(x_axis_speed, 0),
			collision_layer,
			collision_mask,
			0
		)
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(x_axis_speed, 20),
			collision_layer,
			collision_mask,
			0
		)
	return true
