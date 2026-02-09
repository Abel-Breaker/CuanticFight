extends Node2D

enum CameraMode { SINGLE, SPLIT }

@export var split_distance: float = 400.0
@export var transition_speed: float = 5.0

@onready var cam_single: Camera2D = $CameraSingle

@onready var split_ui: Control = $CanvasLayer/SplitUI
@onready var cam_p1: Camera2D = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer/SubViewport/CameraP1
@onready var cam_p2: Camera2D = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer2/SubViewport/CameraP2
@onready var subviewport_p1: SubViewport = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer/SubViewport
@onready var subviewport_p2: SubViewport = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer2/SubViewport
@onready var viewport_container_p1: SubViewportContainer = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer
@onready var viewport_container_p2: SubViewportContainer = $CanvasLayer/SplitUI/HBoxContainer/SubViewportContainer2

var players: Array[CharacterParent] = []
var mode: CameraMode = CameraMode.SINGLE

func _ready():
	subviewport_p1.world_2d = get_viewport().world_2d
	subviewport_p2.world_2d = get_viewport().world_2d

	# Diabolic, if you don´t call SPLIT first It doesnt work
	set_mode(CameraMode.SPLIT)
	set_mode(CameraMode.SINGLE)


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
		cam_single.enabled = true
		split_ui.visible = false
		viewport_container_p1.visible = false
		viewport_container_p2.visible = false
		cam_p1.enabled = false
		cam_p2.enabled = false

	else:
		cam_single.enabled = false
		split_ui.visible = true
		viewport_container_p1.visible = true
		viewport_container_p2.visible = true
		cam_p1.enabled = true
		cam_p2.enabled = true


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
