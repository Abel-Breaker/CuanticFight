extends Node

@onready var quantic_proyectile_scene = preload("res://scenes/characters/Proyectile.tscn")
@onready var classic_proyectile_scene = preload("res://scenes/characters/ClassicProyectile.tscn")

enum ProyectileType {QUANTIC, CLASSIC}

const CLEAN_PROYECTILE_TIME = 3

func free_proyectile_and_timer(proyectile, timer):
	if is_instance_valid(proyectile):
		proyectile.queue_free()
	timer.queue_free()

func spawn_proyectile(type : ProyectileType, global_position: Vector2, velocity : Vector2, layer: int, mask: int, gravity_scale: float, dealing_dmg: int):
	var proyectile : RigidBody2D
	if type == ProyectileType.QUANTIC:
		proyectile = quantic_proyectile_scene.instantiate()
	else:
		proyectile = classic_proyectile_scene.instantiate()
	proyectile.collision_layer = layer
	proyectile.collision_mask = mask
	proyectile.gravity_scale = gravity_scale
	proyectile.global_position = global_position
	proyectile.linear_velocity = velocity
	proyectile.set_meta("DMG", dealing_dmg)

	
	var timer = Timer.new()
	timer.wait_time = CLEAN_PROYECTILE_TIME
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(free_proyectile_and_timer.bind(proyectile, timer), CONNECT_ONE_SHOT)
	
	var scene_root : Node = get_tree().root
	scene_root.add_child(proyectile)
	scene_root.add_child(timer)
