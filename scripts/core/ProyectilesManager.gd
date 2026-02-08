extends Node

@onready var proyectile_scene = preload("res://scenes/characters/Proyectile.tscn")

const CLEAN_PROYECTILE_TIME = 10



func spawn_proyectile(global_position: Vector2, velocity : Vector2, layer: int, mask: int, gravity_scale: float):
	var proyectile : RigidBody2D = proyectile_scene.instantiate()
	proyectile.collision_layer = layer
	proyectile.collision_mask = mask
	proyectile.gravity_scale = gravity_scale
	proyectile.global_position = global_position
	proyectile.linear_velocity = velocity
	#TODO: Set the animation of the proyectile
	
	var timer = Timer.new()
	timer.wait_time = CLEAN_PROYECTILE_TIME
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func ():
		proyectile.queue_free()
		timer.queue_free()
	, CONNECT_ONE_SHOT)
	
	var scene_root : Node = get_tree().root
	scene_root.add_child(proyectile)
	scene_root.add_child(timer)
