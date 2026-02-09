extends Area2D

class_name EspecialAttack

var character : CharacterParent
var characterClone : CharacterParent
var isActive : bool = false

@onready var Cooldown : Timer = $Cooldown

var canBeUsed : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Cooldown.timeout.connect(updateUsability)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func setup(inCharacter : CharacterParent) -> void:
	character = inCharacter
	if character.charID == 1:
		set_collision_mask(2)
	else:
		set_collision_mask(1)

##### AUx funCTiON
func updateUsability():
		canBeUsed = true

func _exit_tree() -> void:
	if Cooldown.timeout.is_connected(updateUsability):
		Cooldown.timeout.disconnect(updateUsability)

# Returns true if succesfully used and false if cannot use for any reason
func try_to_use() -> bool:
	if not canBeUsed: return false
	
	canBeUsed = false
	isActive = true
	duplicate_character()
	return true


func duplicate_character() -> void:
	characterClone = character.duplicate()
	
	character.get_parent().add_child(characterClone)
	characterClone.position = characterClone.position+ Vector2(-100,0)
	
	characterClone.especialAttack.characterClone = character
	characterClone.especialAttack.isActive = true
	characterClone.especialAttack.canBeUsed = false
	
	characterClone.request_anim("especial_attack")
	SignalContainer.player_duplicated_himself.emit(character.charID)

# Returns true the owner should take the damage and false if not
func end_duplication_character() -> bool:
	if isActive:
		isActive = false
		Cooldown.start()
		var im_real = randf() < 0.5
		if im_real:
			SignalContainer.player_determined_himself.emit(character.charID)
			characterClone.queue_free()
			return true
		else:
			character.queue_free()
			return false
	return true
		
