extends Node

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var stage_music: AudioStreamPlayer = $StageMusic
@onready var heartbeat_timer: Timer = $HeartbeatTimer
@onready var heartbeat_sound: AudioStreamPlayer = $HeartbeatSound


var current_track: AudioStreamPlayer
var low_health_filter: AudioEffectFilter

func _ready() -> void:
	var ind = AudioServer.get_bus_index("Music")
	#print("DEBUG: bus_index: " + str(ind))
	low_health_filter = AudioEffectFilter.new()
	AudioServer.add_bus_effect(ind, low_health_filter)
	low_health_filter.cutoff_hz = 20000
	
	heartbeat_timer.timeout.connect(on_heartbeat)
	
	set_bus_volume("Master", 50)
	set_bus_volume("Music", 20)
	set_bus_volume("SFX", 20)

func setup():
	menu_music.stream = load("res://assets/music/menu_theme.ogg")
	stage_music.stream = load("res://assets/music/main_stage.ogg")

func on_heartbeat():
	heartbeat_sound.play()

func play_menu_music():
	crossfade_to(menu_music, 1.0)

func play_stage_music(stage_name: String):
	var stream = load("res://assets/music/%s.ogg" % stage_name)
	stage_music.stream = stream
	crossfade_to(stage_music, 1.5)

func crossfade_to(new_track: AudioStreamPlayer, fade_time: float):
	if current_track == new_track: return
	
	if current_track:
		var tween = create_tween()
		tween.tween_property(current_track, "volume_db", -80.0, fade_time)
		tween.tween_callback(current_track.stop)
	
	new_track.stream.set("loop", true)
	new_track.volume_db = -80.0
	new_track.play()
	
	var tween2 = create_tween()
	tween2.tween_property(new_track, "volume_db", 0.0, fade_time)
	
	current_track = new_track

func on_player_low_health(_player_id: int, health_percent: float):
	var cutoff = lerp(2000.0, 20000.0, health_percent)
	low_health_filter.cutoff_hz = cutoff
	if health_percent < 0.3:
		if heartbeat_timer.is_stopped():
			heartbeat_timer.start()


func reset_low_health_effects():
	low_health_filter.cutoff_hz = 20000.0
	if not heartbeat_timer.is_stopped():
		heartbeat_timer.stop()

func set_bus_volume(bus_name: String, volume_percent: float):
	# Convert 0-100% to -80dB to 0dB
	var db = linear_to_db(volume_percent / 100.0)
	db = clamp(db, -80.0, 0.0)

	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, db)
	else:
		push_error("Audio bus not found: ", bus_name)

func get_bus_volume(bus_name: String) -> float:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var db = AudioServer.get_bus_volume_db(bus_idx)
		# Convert dB back to 0-100%
		return db_to_linear(db) * 100.0
	return 0.0

static func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)

static func db_to_linear(db: float) -> float:
	if db <= -80.0:
		return 0.0
	return pow(10.0, db / 20.0)
