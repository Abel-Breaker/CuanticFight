extends Area2D

class_name EspecialAttack

var character : CharacterParent
var characterClone : CharacterParent
var isActive : bool = false

@onready var Cooldown : Timer = $Cooldown
@onready var front_view_raycast: RayCast2D = $FrontViewRaycast

var spawnPoint : Vector2 
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
	#print("Trying")
	if not canBeUsed: return false
	#print("USED")
	canBeUsed = false
	isActive = true
	duplicate_character()
	return true


func duplicate_character() -> void:
	characterClone = character.duplicate()
	
	
	for i in range(4):
		if get_parent().isLookingLeft:
			spawnPoint = Vector2(-100, 0)
		else:
			spawnPoint = Vector2(100, 0)
		spawnPoint = (3-i) * spawnPoint
		if i==3: 
			spawnPoint += Vector2(0,-100)
		# ----- RAYCAST
		front_view_raycast.global_position = get_parent().global_position + spawnPoint
		front_view_raycast.target_position = Vector2(1,0)
		front_view_raycast.collide_with_bodies = true
		front_view_raycast.force_raycast_update()
		if front_view_raycast.is_colliding():
			'''
			#-----
			var line = Line2D.new()
			line.add_point(front_view_raycast.global_position)
			line.add_point(front_view_raycast.global_position + front_view_raycast.target_position)
			line.width = 2
			line.default_color = Color.YELLOW
			get_tree().root.add_child(line)
			var line2 = Line2D.new()
			line2.add_point(front_view_raycast.global_position)
			line2.add_point(front_view_raycast.global_position + Vector2(4,0))
			line2.width = 2
			line2.default_color = Color.RED
			get_tree().root.add_child(line2)
			
			#-----
			'''
			spawnPoint += Vector2(0,-100)
			
			print("COLLIDING")
			front_view_raycast.global_position = get_parent().global_position + spawnPoint
			front_view_raycast.target_position = Vector2(1,0)
			front_view_raycast.collide_with_bodies = true
			front_view_raycast.force_raycast_update()
			if not front_view_raycast.is_colliding():
				#print("NOTCOLLIDING2")
				break
			#else: 
				#print("COLLIDING2")
		else:
			#print("NOTCOLLIDING")
			break
		
	
	character.get_parent().add_child(characterClone)
	characterClone.position = characterClone.position+ spawnPoint
	
	characterClone.current_health = character.current_health
	characterClone.especialAttack.characterClone = character
	characterClone.especialAttack.isActive = true
	characterClone.especialAttack.canBeUsed = false
	
	characterClone.request_anim("especial_attack")
	SignalContainer.player_duplicated_himself.emit(character.charID)

# Returns true the owner should take the damage and false if not
func end_duplication_character() -> bool:
	if isActive:
		if character.is_queued_for_deletion():
			#print("I AM ALREADY A FAKE")
			return false
		elif characterClone.is_queued_for_deletion():
			#print("I AM ALREADY REAL")
			return true
		isActive = false
		
		var im_real = randf() < 0.5
		if im_real:
			#print("I_AM_REAL")
			characterClone.queue_free()
			Cooldown.start()
			call_deferred("on_duplication_determined")
			return true
		else:
			#print("I_AM_FAKE")
			character.queue_free()
			characterClone.especialAttack.Cooldown.start()
			call_deferred("on_duplication_determined")
			return false
	return true

func on_duplication_determined():
	SignalContainer.player_determined_himself.emit(character.charID)
