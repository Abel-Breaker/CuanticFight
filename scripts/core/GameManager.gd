extends Node

enum GameState {MainMenu, Playing, CombatEnded, Paused}

@onready var pause_scene : Resource = preload("res://scenes/ui/PauseMenu.tscn")
var game_ended_scene_path : String = "res://scenes/ui/GameEndOverlay.tscn"
var main_menu_scene_path : String = "res://scenes/ui/MainMenu.tscn"
var game_scene_path : String = "res://scenes/stages/TestingMap.tscn" #TODO: Change for the final game scene

var curr_game_state : GameState = GameState.MainMenu

var pause_overlay : Panel
var game_ended_overlay : CanvasLayer


func _ready() -> void:
	SignalContainer.program_close.connect(close_program)
	SignalContainer.game_start.connect(start_game)
	
	SignalContainer.game_pause.connect(pause_game)
	SignalContainer.game_resume.connect(resume_game)
	
	SignalContainer.game_finish.connect(finish_game)
	SignalContainer.game_exit.connect(exit_game)
	SignalContainer.game_replay.connect(replay_game)
	


func close_program(exit_code : int):
	if curr_game_state != GameState.MainMenu:
		return
	
	get_tree().quit(exit_code)
	
func start_game():
	if curr_game_state != GameState.MainMenu:
		return
	curr_game_state = GameState.Playing

	change_scene(game_scene_path)	


func exit_game():
	if curr_game_state != GameState.Paused and curr_game_state != GameState.CombatEnded:
		return
	curr_game_state = GameState.MainMenu
	
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
	
	var game_ended_scene = load(game_ended_scene_path)
	game_ended_overlay = game_ended_scene.instantiate()
	get_tree().root.add_child(game_ended_overlay)
	game_ended_overlay.set_winner_text(winner_player)


func replay_game():
	if curr_game_state != GameState.CombatEnded:
		return
	curr_game_state = GameState.Playing
	
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

func get_players() -> Array[CharacterBody2D]:
	if curr_game_state == GameState.MainMenu:
		return []
	
	var combat_manager = get_tree().current_scene
	return combat_manager.get_players()
	
