extends Node

@onready var pause_scene : Resource = preload("res://scenes/ui/PauseMenu.tscn")
var game_ended_scene_path : String = "res://scenes/ui/GameEndOverlay"
var main_menu_scene_path : String = "res://scenes/ui/MainMenu.tscn"
var game_scene_path : String = "res://scenes/stages/TestingMap.tscn" #TODO: Change for the final game scene

var pause_overlay : Panel
var game_ended_overlay : Panel

func _ready() -> void:
	SignalContainer.program_close.connect(close_program, CONNECT_ONE_SHOT)
	SignalContainer.game_start.connect(start_game, CONNECT_ONE_SHOT)
	


func close_program(exit_code : int):
	get_tree().quit(exit_code)
	
func start_game():
	change_scene(game_scene_path)
	SignalContainer.game_pause.connect(pause_game)
	SignalContainer.game_finish.connect(finish_game, CONNECT_ONE_SHOT)
	SignalContainer.game_exit.connect(exit_game, CONNECT_ONE_SHOT)

func exit_game():
	change_scene(main_menu_scene_path)
	SignalContainer.game_start.connect(start_game, CONNECT_ONE_SHOT)

func pause_game():
	get_tree().paused = true
	pause_overlay = pause_scene.instantiate()
	get_tree().root.add_child(pause_overlay)
	SignalContainer.game_resume.connect(resume_game, CONNECT_ONE_SHOT)

func resume_game():
	pause_overlay.queue_free()
	get_tree().paused = false

func finish_game(winner_player: int):
	var game_ended_scene = load(game_ended_scene_path)
	game_ended_overlay = game_ended_scene.instantiate()
	game_ended_overlay.set_winner_text(winner_player)
	get_tree().root.add_child(game_ended_overlay)
	SignalContainer.game_replay.connect(replay_game, CONNECT_ONE_SHOT)

func replay_game():
	change_scene(game_scene_path)

func change_scene(new_scene_path: String):
	var curr_scene = get_tree().current_scene
	
	var new_scene = load(new_scene_path).instantiate()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	if curr_scene:
		curr_scene.queue_free()
