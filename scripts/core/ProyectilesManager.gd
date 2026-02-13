extends Node

@onready var quantic_proyectile_scene = preload("res://scenes/characters/Proyectile.tscn")
@onready var classic_proyectile_scene = preload("res://scenes/characters/ClassicProyectile.tscn")

enum ProyectileType {QUANTIC, CLASSIC}

const CLEAN_PROYECTILE_TIME = 3
const DESTROY_PROYECTILE_ANIM_TIME = 0.25

"""
func free_proyectile_resources(proyectile, destroy_anim_timer):
	if is_instance_valid(proyectile):
		proyectile.queue_free()
	destroy_anim_timer.queue_free()

func destroy_proyectile(body, proyectile, timeout_timer):
	var destroy_anim_timer = Timer.new()
	destroy_anim_timer.wait_time = DESTROY_PROYECTILE_ANIM_TIME
	destroy_anim_timer.one_shot = true
	destroy_anim_timer.autostart = true
	destroy_anim_timer.timeout.connect(free_proyectile_resources.bind(proyectile, destroy_anim_timer), CONNECT_ONE_SHOT)
	get_tree().root.add_child(destroy_anim_timer)
	print("DESTROYING: " + proyectile.name)
	proyectile.collision_layer = 0
	proyectile.collision_mask = 0
	proyectile.linear_velocity = Vector2(0, 0)
	
	proyectile.animated_sprite.visible = false
	proyectile.impact_sprite.visible = true
	
	proyectile.freeze = true
	#if body:
	
	
	
	
	if not timeout_timer.is_stopped():
		timeout_timer.stop()
	timeout_timer.queue_free()
	if proyectile.body_entered.is_connected(destroy_proyectile):
		proyectile.body_entered.disconnect(destroy_proyectile)
	if timeout_timer.timeout.is_connected(destroy_proyectile):
		timeout_timer.timeout.disconnect(destroy_proyectile)
"""

#---------------------------------------------------------


func spawn_proyectile(owner_id: int, type : ProyectileType, global_position: Vector2, velocity : Vector2, layer: int, mask: int, _gravity_scale: float, dealing_dmg: int, play_sound: bool, is_recolor: bool):
	var proyectile : Proyectile
	if type == ProyectileType.QUANTIC:
		proyectile = quantic_proyectile_scene.instantiate()
	else:
		proyectile = classic_proyectile_scene.instantiate()
		
	proyectile.setup(owner_id, dealing_dmg, layer, mask, play_sound, is_recolor)
	proyectile.global_position = global_position
	proyectile.linear_velocity = velocity
	
	#proyectile.collision_layer = layer
	#proyectile.collision_mask = mask
	#proyectile.gravity_scale = gravity_scale
	
	#proyectile.set_meta("DMG", dealing_dmg)
	
	#var timeout_timer = Timer.new()
	#timeout_timer.wait_time = CLEAN_PROYECTILE_TIME
	#timeout_timer.one_shot = true
	#timeout_timer.autostart = true
	#print("SHOOT: " + proyectile.name)
	#proyectile.body_entered.connect(destroy_proyectile.bind(proyectile, timeout_timer), CONNECT_ONE_SHOT)
	#timeout_timer.timeout.connect(destroy_proyectile.bind(null, proyectile, timeout_timer), CONNECT_ONE_SHOT)
	
	var scene_root : Node = get_tree().root
	scene_root.add_child(proyectile)
	#scene_root.add_child(timeout_timer)
