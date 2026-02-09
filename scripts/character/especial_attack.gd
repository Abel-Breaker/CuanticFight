extends Area2D

class_name EspecialAttack

var character : CharacterParent
var characterClone : CharacterParent
var isActive : bool = false

@onready var Cooldown : Timer = $Cooldown

var canBeUsed : bool = true


func _ready() -> void:
	Cooldown.timeout.connect(updateUsability)
	SignalContainer.player_determined_himself.connect(player_determined_himself)

func player_determined_himself(player_id: int):
	if player_id != character.charID: return
	
	if not self.is_queued_for_deletion():
		characterClone = null
		isActive = false


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
	SignalContainer.player_determined_himself.disconnect(player_determined_himself)

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
			characterClone.queue_free()
			call_deferred("on_duplication_determined")
			return true
		else:
			character.queue_free()
			call_deferred("on_duplication_determined")
			return false
	return true

func on_duplication_determined():
	SignalContainer.player_determined_himself.emit(character.charID)
