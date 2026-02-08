extends Node2D

class_name RangeAttack

var character: CharacterParent

@onready var cooldown : Timer = $Cooldown
@onready var shoot_position : Marker2D = $Marker2D


var canBeUsed : bool = true
var collision_layer: int
var collision_mask: int

func _ready() -> void:
	cooldown.timeout.connect(updateUsability)

func setup(inCharacter: CharacterParent) -> void:
	character = inCharacter

	if character.charID == 1:
		collision_mask = 2
		collision_layer = 8
	else:
		collision_mask = 1
		collision_layer = 16


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
	
	canBeUsed = false
	cooldown.start()
	
	if enemy_is_looking_at_me: #Shooting like a physical particle
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position, 
			Vector2(500,0),
			collision_layer,
			collision_mask,
			0
		)
		
	else: #Shooting like a wave
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(500, -20),
			collision_layer,
			collision_mask,
			0
		)
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(500, 0),
			collision_layer,
			collision_mask,
			0
		)
		ProyectilesManager.spawn_proyectile(
			shoot_position.global_position,
			Vector2(500, 20),
			collision_layer,
			collision_mask,
			0
		)
	return true
