extends Node2D

class_name RangeAttack

var character: CharacterParent


@onready var cooldown : Timer = $Cooldown
@onready var shoot_position : Marker2D = $Marker2D

@export var multiBulletsAmount: int = 5
@export var single_bullet_speed: float = 500
@export var single_bullet_damage: int = 20
@export var multi_bullet_speed: float = 300
@export var multi_bullet_damage: int = 5
@export var proyectile_type : ProyectilesManager.ProyectileType = ProyectilesManager.ProyectileType.QUANTIC

var canBeUsed : bool = true
var collision_layer: int
var collision_mask: int

func _ready() -> void:
	cooldown.timeout.connect(updateUsability)



func setup(inCharacter: CharacterParent) -> void:
	character = inCharacter

	if character.charID == 1: #TODO: Make it collide with the environment only
		collision_mask = 0
		collision_layer = 8
	else:
		collision_mask = 0
		collision_layer = 4


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
	
	if look_dir_modifier * shoot_position.position.x < 0:
		shoot_position.position.x *= -1
	
	canBeUsed = false
	cooldown.start()
	
	if enemy_is_looking_at_me: #Shooting like a physical particle
		ProyectilesManager.spawn_proyectile(
			proyectile_type,
			shoot_position.global_position, 
			Vector2(look_dir_modifier * single_bullet_speed,0),
			collision_layer,
			collision_mask,
			0,
			single_bullet_damage
		)
		
	else: #Shooting like a wave
		var x_axis_speed: float = look_dir_modifier * multi_bullet_speed
		for i in range(multiBulletsAmount):
			ProyectilesManager.spawn_proyectile(
			proyectile_type,
			shoot_position.global_position,
			Vector2(x_axis_speed, (i - multiBulletsAmount/2)*20),
			collision_layer,
			collision_mask,
			0,
			multi_bullet_damage
			)
	return true
