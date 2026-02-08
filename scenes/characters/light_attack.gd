extends Area2D

class_name lightAttackClass

var character : CharacterParent

@onready var EffectWindow : Timer = $EffectWindow
@onready var Cooldown : Timer = $Cooldown

var canBeUsed : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setup(inCharacter : CharacterParent) -> void:
	character = inCharacter
	
	EffectWindow.timeout.connect(updateMonitoring)
			
	Cooldown.timeout.connect(updateUsability)
	
	if character.charID == 1:
		set_collision_mask(2)
	else:
		set_collision_mask(1)

##### AUx funCTiONs

func updateMonitoring(): #TODO: Change this dirty approach (is just for testing)
		monitoring = false
func updateUsability(): #TODO: Change this dirty approach (is just for testing)
		canBeUsed = true

func _exit_tree() -> void:
	if EffectWindow.timeout.is_connected(updateMonitoring):
		EffectWindow.timeout.disconnect(updateMonitoring)
	if Cooldown.timeout.is_connected(updateUsability):
		Cooldown.timeout.disconnect(updateUsability)

# Returns true if succesfully used and false if cannot use for any reason
func try_to_use() -> bool:
	
	if canBeUsed:
		canBeUsed = false
		monitoring = true
		Cooldown.start()
		EffectWindow.start()
	return true
