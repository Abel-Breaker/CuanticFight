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

var camera_updates_are_enabled: bool = false

func _ready():
	subviewport_p1.world_2d = get_viewport().world_2d
	subviewport_p2.world_2d = get_viewport().world_2d
	
	# Inicializamos cámaras con posición y zoom inicial
	var start_offset: Vector2 = Vector2(750, 750)  # Ajusta según el efecto que quieras
	var start_zoom: float = 4.0  # Zoom inicial muy alejado

	# Posición inicial: muy abajo a la derecha desde el centro de los jugadores
	cam_single.global_position = start_offset

	# Zoom inicial grande
	cam_single.zoom = Vector2.ONE * start_zoom

	# Diabolic, if you don´t call SPLIT first It doesnt work
	set_mode(CameraMode.SPLIT)
	set_mode(CameraMode.SINGLE)

func enable_camera_updates(b: bool):
	camera_updates_are_enabled = b

# Check distance between players and set camera mode
func _physics_process(delta):
	if not camera_updates_are_enabled: return
	
	players = GameManager.get_players()
	
	if players.size() < 4:
		return
	
	var p1 := get_pair_center(players[0], players[1])
	var p2 := get_pair_center(players[2], players[3])

	if (p1.distance_to(p2)) > split_distance:
		set_mode(CameraMode.SPLIT)
	else:
		set_mode(CameraMode.SINGLE)
	
	# For smoother transition update all
	update_single_camera(delta)
	update_split_cameras(delta)
		

func get_pair_center(p1: CharacterParent, p2: CharacterParent) -> Vector2:
	var has_p1 := GameManager.player_exists(p1)
	var has_p2 := GameManager.player_exists(p2)
	if has_p2: # Superposition
		return (p1.global_position + p2.global_position) * 0.5
	else:
		return p1.global_position


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
	var count := players.size()
	if count == 0:
		return

	# Inicializar límites con el primer jugador
	var min_pos: Vector2 = players[0].global_position
	var max_pos: Vector2 = players[0].global_position

	# Calcular bounding box de todos los jugadores
	for i in range(1, count):
		if(GameManager.player_exists(players[i])):
			var p: Vector2 = players[i].global_position
			min_pos.x = min(min_pos.x, p.x)
			min_pos.y = min(min_pos.y, p.y)
			max_pos.x = max(max_pos.x, p.x)
			max_pos.y = max(max_pos.y, p.y)

	# Centro de la cámara
	var center: Vector2 = (min_pos + max_pos) * 0.5

	# Distancia máxima entre jugadores
	var dx: float = max_pos.x - min_pos.x
	var dy: float = max_pos.y - min_pos.y
	var max_dist: float = max(dx, dy)

	# Zoom objetivo
	var t: float = clamp(max_dist / split_distance, 0.0, 1.0)
	var target_zoom: float = lerp(1.5, 0.5, t)

	# Suavizado de cámara
	cam_single.global_position = cam_single.global_position.lerp(
		center,
		transition_speed * delta
	)
	cam_single.zoom = cam_single.zoom.lerp(
		Vector2.ONE * target_zoom,
		transition_speed * delta
	)


# --------------------------------------------------
func update_split_cameras(delta: float) -> void:
	# --- PARES DE JUGADORES ---
	var p1_pos: Vector2 = get_pair_center(players[0], players[1])
	var p2_pos: Vector2 = get_pair_center(players[2], players[3])

	# --- ACTUALIZAR POSICIÓN SUAVIZADA ---
	cam_p1.global_position = cam_p1.global_position.lerp(p1_pos, transition_speed * delta)
	cam_p2.global_position = cam_p2.global_position.lerp(p2_pos, transition_speed * delta)

	# --- ZOOM PARA CADA PAREJA ---
	var zoom_p1: float = calculate_pair_zoom(players[0], players[1])
	var zoom_p2: float = calculate_pair_zoom(players[2], players[3])

	cam_p1.zoom = cam_p1.zoom.lerp(Vector2.ONE * zoom_p1, transition_speed * delta)
	cam_p2.zoom = cam_p2.zoom.lerp(Vector2.ONE * zoom_p2, transition_speed * delta)


# Calcula el zoom basado en la distancia entre los jugadores de un par
func calculate_pair_zoom(player_a: CharacterParent, player_b: CharacterParent) -> float:
	var has_a := GameManager.player_exists(player_a)
	var has_b := GameManager.player_exists(player_b)

	if not has_a and not has_b:
		return 1.0 # Zoom por defecto si no hay jugadores
	elif has_a and not has_b:
		return 1.0 # Solo un jugador: zoom neutro
	elif not has_a and has_b:
		return 1.0 # Solo un jugador: zoom neutro

	# Ambos jugadores existen: calculamos la bounding box
	var min_pos: Vector2 = player_a.global_position
	var max_pos: Vector2 = player_a.global_position

	var positions := [player_a.global_position, player_b.global_position]
	for p in positions:
		min_pos.x = min(min_pos.x, p.x)
		min_pos.y = min(min_pos.y, p.y)
		max_pos.x = max(max_pos.x, p.x)
		max_pos.y = max(max_pos.y, p.y)

	var dx: float = max_pos.x - min_pos.x
	var dy: float = max_pos.y - min_pos.y
	var max_dist: float = max(dx, dy)

	var t: float = clamp(max_dist / split_distance, 0.0, 1.0)
	return lerp(1.5, 0.5, t)
