extends Area2D

class_name LightAttack

var character : CharacterParent

@onready var EffectWindow : Timer = $EffectWindow
@onready var Cooldown : Timer = $Cooldown

@export var damage : int

var canBeUsed : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(deal_light_attack_damage)
	EffectWindow.timeout.connect(updateMonitoring)
	Cooldown.timeout.connect(updateUsability)



func setup(inCharacter : CharacterParent) -> void:
	character = inCharacter
	if character.charID == 1:
		set_collision_mask(2)
	else:
		set_collision_mask(1)
		print(character.charID)

##### AUx funCTiONs
func updateMonitoring(): 
		monitoring = false
func updateUsability():
		canBeUsed = true

func _exit_tree() -> void:
	if EffectWindow.timeout.is_connected(updateMonitoring):
		EffectWindow.timeout.disconnect(updateMonitoring)
	if Cooldown.timeout.is_connected(updateUsability):
		Cooldown.timeout.disconnect(updateUsability)
	if area_entered.is_connected(deal_light_attack_damage):
		area_entered.disconnect(deal_light_attack_damage)

# Returns true if succesfully used and false if cannot use for any reason
func try_to_use() -> bool:
	
	if canBeUsed:
		canBeUsed = false
		monitoring = true
		Cooldown.start()
		EffectWindow.start()
		return true
	return false



	
func deal_light_attack_damage(area: Area2D):

	var enemy = area.get_parent()
	enemy.received_damage(damage) 
	#print("the parent is " + str(area.get_parent()))
