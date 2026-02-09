extends Node

enum GameState {MainMenu, Playing, CombatEnded, Paused}

@onready var pause_scene : Resource = preload("res://scenes/ui/PauseMenu.tscn")
var game_ended_scene_path : String = "res://scenes/ui/GameEndOverlay.tscn"
var main_menu_scene_path : String = "res://scenes/ui/MainMenu.tscn"
var game_scene_path : String = "res://scenes/stages/TestingMap.tscn" #TODO: Change for the final game scene
@onready var game_end_delay: Timer = $GameEndDelay

var curr_game_state : GameState = GameState.MainMenu

var pause_overlay : CanvasLayer
var game_ended_overlay : CanvasLayer
var last_winner_id: int

func _ready() -> void:
	SignalContainer.program_close.connect(close_program)
	SignalContainer.game_start.connect(start_game)
	
	SignalContainer.game_pause.connect(pause_game)
	SignalContainer.game_resume.connect(resume_game)
	
	SignalContainer.game_finish.connect(finish_game)
	SignalContainer.game_exit.connect(exit_game)
	SignalContainer.game_replay.connect(replay_game)
	
	call_deferred("setup")

func setup():
	game_end_delay.timeout.connect(on_game_end_delay_timer_timeout)
	AudioManager.setup()
	AudioManager.play_menu_music()
	

func on_game_end_delay_timer_timeout():
	var game_ended_scene = load(game_ended_scene_path)
	game_ended_overlay = game_ended_scene.instantiate()
	get_tree().root.add_child(game_ended_overlay)
	game_ended_overlay.set_winner_text(last_winner_id)
	last_winner_id = 0

func close_program(exit_code : int):
	if curr_game_state != GameState.MainMenu:
		return
	
	get_tree().quit(exit_code)
	
func start_game():
	if curr_game_state != GameState.MainMenu:
		return
	curr_game_state = GameState.Playing
	AudioManager.play_stage_music("main_stage")
	change_scene(game_scene_path)	


func exit_game():
	if curr_game_state != GameState.Paused and curr_game_state != GameState.CombatEnded:
		return
	if curr_game_state == GameState.Paused:
		resume_game()
	curr_game_state = GameState.MainMenu
	AudioManager.reset_low_health_effects()
	AudioManager.play_menu_music()

	if game_ended_overlay:
		game_ended_overlay.queue_free()
		game_ended_overlay = null
	if pause_overlay:
		pause_overlay.queue_free()
		pause_overlay = null
	change_scene(main_menu_scene_path)


func pause_game():
	if curr_game_state != GameState.Playing:
		return
	curr_game_state = GameState.Paused
	
	get_tree().paused = true
	pause_overlay = pause_scene.instantiate()
	get_tree().root.add_child(pause_overlay)


func resume_game():
	if curr_game_state != GameState.Paused:
		return
	curr_game_state = GameState.Playing
	
	pause_overlay.queue_free()
	pause_overlay = null
	get_tree().paused = false

func finish_game(winner_player: int):
	if curr_game_state != GameState.Playing:
		return
	curr_game_state = GameState.CombatEnded
	
	last_winner_id = winner_player
	game_end_delay.start()


func replay_game():
	if curr_game_state != GameState.CombatEnded:
		return
	curr_game_state = GameState.Playing
	AudioManager.reset_low_health_effects()
	
	game_ended_overlay.queue_free()
	game_ended_overlay = null
	change_scene(game_scene_path)


func change_scene(new_scene_path: String):
	var curr_scene = get_tree().current_scene
	
	var new_scene = load(new_scene_path).instantiate()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	if curr_scene:
		curr_scene.queue_free()


func get_players() -> Array[CharacterParent]:
	if curr_game_state == GameState.MainMenu: # != PLAYING?
		return []
	
	var combat_manager = get_tree().current_scene
	return combat_manager.get_players()
	
func player_exists(p: CharacterParent) -> bool:
	return p != null and is_instance_valid(p)
	
func get_combat_manager() -> CombatManager:
	if curr_game_state == GameState.MainMenu: return null
	
	var combat_manager = get_tree().current_scene
	return combat_manager
