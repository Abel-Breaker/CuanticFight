extends Node2D

enum CameraMode { SINGLE, SPLIT }

@export var split_distance: float = 400.0
@export var transition_speed: float = 5.0

@onready var cam_single: Camera2D = $CameraSingle

@onready var split_ui: Control = $SplitUI
@onready var cam_p1: Camera2D = $SplitUI/HBoxContainer/SubViewportContainer/SubViewport/CameraP1
@onready var cam_p2: Camera2D = $SplitUI/HBoxContainer/SubViewportContainer2/SubViewport/CameraP2

var players: Array[CharacterParent] = []
var mode: CameraMode = CameraMode.SINGLE

func _ready():
	set_mode(CameraMode.SINGLE)
	var screen_size = get_viewport_rect().size
	$SplitUI/HBoxContainer/SubViewportContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$SplitUI/HBoxContainer/SubViewportContainer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL


# Check distance between players and set camera mode
func _process(delta):
	players = GameManager.get_players()
	
	if players.size() < 2:
		return

	var p1 := players[0].global_position
	var p2 := players[1].global_position

	if (p1.distance_to(p2)) > split_distance:
		set_mode(CameraMode.SPLIT)
		update_split_cameras(delta)
	else:
		set_mode(CameraMode.SINGLE)
		update_single_camera(delta)
		


func set_mode(new_mode: CameraMode):
	if mode == new_mode:
		return

	mode = new_mode

	if mode == CameraMode.SINGLE:
		cam_single.enabled = true  # activamos la cámara principal
		split_ui.visible = false    # ocultamos la pantalla dividida
	else:
		cam_single.enabled = false # desactivamos la cámara principal
		split_ui.visible = true    # activamos la pantalla dividida



# --------------------------------------------------

func update_single_camera(delta):
	var p1: Vector2 = players[0].global_position
	var p2: Vector2 = players[1].global_position

	var center: Vector2 = (p1 + p2) * 0.5

	var dx: float = abs(p1.x - p2.x)
	var dy: float = abs(p1.y - p2.y)
	var max_dist: float = max(dx, dy)

	var t: float = clamp(max_dist / split_distance, 0.0, 1.0)
	var target_zoom: float = lerp(1.5, 0.5, t)

	# Aplicar suavizado a la cámara
	cam_single.global_position = cam_single.global_position.lerp(center, transition_speed * delta)
	cam_single.zoom = cam_single.zoom.lerp(Vector2.ONE * target_zoom, transition_speed * delta)


# --------------------------------------------------

func update_split_cameras(delta):
	var p1_pos = players[0].global_position
	var p2_pos = players[1].global_position

	cam_p1.global_position = cam_p1.global_position.lerp(p1_pos, transition_speed * delta)
	cam_p2.global_position = cam_p2.global_position.lerp(p2_pos, transition_speed * delta)
