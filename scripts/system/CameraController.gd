extends Node2D

enum CameraMode { SINGLE, SPLIT_HORIZONTAL }#, SPLIT_VERTICAL }

@export var single_camera_threshold: float = 400.0  #Pixels before split
@export var transition_speed: float = 5.0
@export var camera_margin: Vector2 = Vector2(100, 50)  #Padding around players

@onready var camera_single : Camera2D = $CameraSingle
@onready var camera_p1 : Camera2D = $CameraP1
@onready var camera_p2 : Camera2D = $CameraP2
@onready var viewport_container : SubViewportContainer = $ViewportContainer

var players = []
var current_mode = CameraMode.SINGLE
var target_mode = CameraMode.SINGLE

func _ready():
	
	#players = get_tree().get_nodes_in_group("players")

	call_deferred("setup")

func setup():
	players = GameManager.get_players()
	
	camera_single.enabled = true
	camera_p1.enabled = false
	camera_p2.enabled = false
	viewport_container.material.set_shader_parameter("split_amount", 0.0)

func _process(delta):
	if players.size() < 2:
		return
	
	# Determine camera mode based on player distance
	var distance = players[0].global_position.distance_to(players[1].global_position)
	var viewport_size = get_viewport().size
	
	
	if distance > single_camera_threshold:
		## Choose split direction based on player positions
		#var x_diff = abs(players[0].global_position.x - players[1].global_position.x)
		#var y_diff = abs(players[0].global_position.y - players[1].global_position.y)
		#
		#if x_diff > y_diff:
		#	target_mode = CameraMode.SPLIT_HORIZONTAL
		#else:
		#	target_mode = CameraMode.SPLIT_VERTICAL
		target_mode = CameraMode.SPLIT_HORIZONTAL
	else:
		target_mode = CameraMode.SINGLE
	
	if current_mode != target_mode:
		transition_to_mode(target_mode, delta)
	
	update_camera_positions(delta)

func update_camera_positions(delta):
	match current_mode:
		CameraMode.SINGLE:
			update_single_camera(delta)
		CameraMode.SPLIT_HORIZONTAL:
			update_split_horizontal(delta)
		#CameraMode.SPLIT_VERTICAL:
		#	update_split_vertical(delta)

func update_single_camera(delta):
	# Center between both players
	var center_pos = (players[0].global_position + players[1].global_position) / 2.0
	
	# Add margin based on player distance
	var distance = players[0].global_position.distance_to(players[1].global_position)
	var target_zoom = clamp(distance / single_camera_threshold, 0.5, 1.5)
	
	# Smooth camera movement
	camera_single.global_position = lerp(
		camera_single.global_position, 
		center_pos, 
		transition_speed * delta
	)
	camera_single.zoom = lerp(
		camera_single.zoom, 
		Vector2.ONE * target_zoom, 
		transition_speed * delta
	)
	
	# Clamp to stage boundaries
	clamp_camera_to_stage(camera_single)

func update_split_horizontal(delta): #TODO: Change so the side of the viewport is attributed to the player that is on that side
	# Left side for P1, right side for P2
	var viewport_size = get_viewport().size
	
	# P1 camera (left half)
	camera_p1.global_position = lerp(
		camera_p1.global_position,
		players[0].global_position,
		transition_speed * delta
	)
	camera_p1.limit_left = -10000
	camera_p1.limit_right = players[1].global_position.x - viewport_size.x / 4
	
	# P2 camera (right half)
	camera_p2.global_position = lerp(
		camera_p2.global_position,
		players[1].global_position,
		transition_speed * delta
	)
	camera_p2.limit_left = players[0].global_position.x + viewport_size.x / 4
	camera_p2.limit_right = 10000
	
	# Set viewport splits
	viewport_container.material.set_shader_parameter("split_position", 0.5)
	viewport_container.material.set_shader_parameter("split_direction", 1)  # 1 = horizontal split

"""
func update_split_vertical(delta):
	# Top for P1, bottom for P2 (useful for platform stages)
	var viewport_size = get_viewport().size
	
	# P1 camera (top half)
	camera_p1.global_position = lerp(
		camera_p1.global_position,
		players[0].global_position,
		transition_speed * delta
	)
	camera_p1.limit_top = -10000
	camera_p1.limit_bottom = players[1].global_position.y - viewport_size.y / 4
	
	# P2 camera (bottom half)
	camera_p2.global_position = lerp(
		camera_p2.global_position,
		players[1].global_position,
		transition_speed * delta
	)
	camera_p2.limit_top = players[0].global_position.y + viewport_size.y / 4
	camera_p2.limit_bottom = 10000
	
	# Set viewport splits
	viewport_container.material.set_shader_parameter("split_position", 0.5)
	viewport_container.material.set_shader_parameter("split_direction", 0)  # 0 = vertical split
"""


func transition_to_mode(new_mode: CameraMode, delta: float):

	current_mode = new_mode
	
	match new_mode:
		CameraMode.SINGLE:
			camera_single.enabled = true
			camera_p1.enabled = false
			camera_p2.enabled = false
			viewport_container.material.set_shader_parameter("split_amount", 0.0)
			
		CameraMode.SPLIT_HORIZONTAL:
			camera_single.enabled = false
			camera_p1.enabled = true
			camera_p2.enabled = true
			# Animate split line
			var tween = create_tween()
			tween.tween_method(
				func(value): viewport_container.material.set_shader_parameter("split_amount", value),
				0.0, 1.0, 0.3
			)

func clamp_camera_to_stage(camera: Camera2D):
	# Assuming you have stage boundaries
	var stage_min = Vector2(-1000, 0)  # Adjust to your stage
	var stage_max = Vector2(1000, 600)
	
	var viewport_half = Vector2(get_viewport().size) * camera.zoom / 2.0
	
	camera.global_position.x = clamp(
		camera.global_position.x,
		stage_min.x + viewport_half.x,
		stage_max.x - viewport_half.x
	)
	camera.global_position.y = clamp(
		camera.global_position.y,
		stage_min.y + viewport_half.y,
		stage_max.y - viewport_half.y
	)
