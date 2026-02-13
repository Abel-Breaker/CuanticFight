extends Node

enum GameState {Cinematic, MainMenu, CharacterSelection, MapSelection, Playing, CombatEnded, Paused}

@onready var pause_scene : Resource = preload("res://scenes/ui/PauseMenu.tscn")
var game_ended_scene_path : String = "res://scenes/ui/GameEndOverlay.tscn"
var main_menu_scene_path : String = "res://scenes/ui/MainMenu.tscn"
var character_selection_menu_scene_path: String = "res://scenes/ui/CharacterSelection.tscn"
var map_selection_menu_scene_path: String = "res://scenes/ui/MapSelector.tscn"
#TODO: Add Title screen
#TODO: Change for the final game scene
var game_scene_path : Array[String] = [\
	"res://scenes/stages/BlueMap.tscn",\
	"res://scenes/stages/GreenMap.tscn",\
	"res://scenes/stages/RedMap.tscn",\
	"res://scenes/stages/Procedural.tscn"\
]
@onready var game_end_delay: Timer = $GameEndDelay

var curr_game_state : GameState = GameState.Cinematic

var pause_overlay : CanvasLayer
var game_ended_overlay : CanvasLayer
var last_winner_id: int
var last_combat_init_data #Has P1Type, P2Type, SoloGame
var selectedMap : int = 0

func _ready() -> void:
	SignalContainer.program_close.connect(close_program)
	
	SignalContainer.game_character_selection.connect(go_to_character_selection)
	SignalContainer.game_map_selection.connect(go_to_map_selection)
	SignalContainer.game_go_back_to_main_menu.connect(go_back_to_main_menu)
	SignalContainer.game_go_back_to_character_selection.connect(go_back_to_character_selection)
	SignalContainer.game_start.connect(start_game)
	
	SignalContainer.game_pause.connect(pause_game)
	SignalContainer.game_resume.connect(resume_game)
	
	SignalContainer.game_finish.connect(finish_game)
	SignalContainer.game_exit.connect(exit_game)
	SignalContainer.game_replay.connect(replay_game)
	
	SignalContainer.game_show_title_screen.connect(on_show_title_screen)
	
	call_deferred("setup")

func setup():
	game_end_delay.timeout.connect(on_game_end_delay_timer_timeout)
	AudioManager.setup()
	#AudioManager.play_menu_music() #TODO: Play music for starting cinematic

func on_show_title_screen():
	if curr_game_state != GameState.Cinematic: return
	curr_game_state = GameState.MainMenu
	change_scene(main_menu_scene_path)
	AudioManager.play_menu_music()

func on_game_end_delay_timer_timeout():
	var game_ended_scene = load(game_ended_scene_path)
	game_ended_overlay = game_ended_scene.instantiate()
	get_tree().root.add_child(game_ended_overlay)
	game_ended_overlay.set_winner_text(last_winner_id, last_combat_init_data.SoloGame)
	last_winner_id = 0

func close_program(exit_code : int):
	if curr_game_state != GameState.MainMenu:
		return
	
	get_tree().quit(exit_code)

func go_back_to_main_menu():
	if curr_game_state != GameState.CharacterSelection: return
	curr_game_state = GameState.MainMenu
	var menu_scene = change_scene(main_menu_scene_path)
	menu_scene.remove_title_overlay()

func go_back_to_character_selection(solo: bool):
	if curr_game_state != GameState.MapSelection: return
	curr_game_state = GameState.CharacterSelection
	var char_sel = change_scene(character_selection_menu_scene_path)
	char_sel.setup(solo)

func go_to_character_selection(solo: bool):
	if curr_game_state != GameState.MainMenu: return
	curr_game_state = GameState.CharacterSelection
	var char_sel = change_scene(character_selection_menu_scene_path)
	char_sel.setup(solo)

func go_to_map_selection(INp1_type: ProyectilesManager.ProyectileType, INp2_type: ProyectilesManager.ProyectileType, INsolo: bool, INrecolorP1 : bool, INrecolorP2 : bool):
	if curr_game_state != GameState.CharacterSelection: return
	curr_game_state = GameState.MapSelection
	var map_sel = change_scene(map_selection_menu_scene_path)
	map_sel.setup(INp1_type, INp2_type, INsolo, INrecolorP1, INrecolorP2)


func start_game(p1_type: ProyectilesManager.ProyectileType, p2_type: ProyectilesManager.ProyectileType, solo: bool, recolorP1:bool, recolorP2:bool, map:int):
	if curr_game_state != GameState.MapSelection:
		return
	curr_game_state = GameState.Playing
	AudioManager.play_stage_music("main_stage")
	selectedMap = map
	change_scene(game_scene_path[selectedMap])
	
	last_combat_init_data = {"P1Type": p1_type, "P2Type": p2_type, "SoloGame": solo, "RecolorP1": recolorP1, "RecolorP2":recolorP2}
	call_deferred("init_combat", last_combat_init_data.P1Type, last_combat_init_data.P2Type, last_combat_init_data.SoloGame, last_combat_init_data.RecolorP1, last_combat_init_data.RecolorP2)

func init_combat(char_type_player1: ProyectilesManager.ProyectileType, char_type_player2: ProyectilesManager.ProyectileType, ai_game: bool, recolorP1:bool, recolorP2:bool):
	var combat_manager = get_combat_manager()
	if not combat_manager: push_error("Not combat_manager loaded to start combat")
	
	combat_manager.setup(char_type_player1, char_type_player2, ai_game, recolorP1, recolorP2)
	# Add Contdown scene
	await show_countdown()

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
	var menu_scene = change_scene(main_menu_scene_path)
	menu_scene.remove_title_overlay()
	last_combat_init_data = null


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
	change_scene(game_scene_path[selectedMap])
	call_deferred("init_combat", last_combat_init_data.P1Type, last_combat_init_data.P2Type, last_combat_init_data.SoloGame, last_combat_init_data.RecolorP1, last_combat_init_data.RecolorP2)



func change_scene(new_scene_path: String):
	var curr_scene = get_tree().current_scene
	
	var new_scene = load(new_scene_path).instantiate()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	if curr_scene:
		curr_scene.queue_free()
	return new_scene


func get_players() -> Array[CharacterParent]:
	if curr_game_state == GameState.MainMenu or curr_game_state == GameState.CharacterSelection: # != PLAYING?
		return []
	
	var combat_manager = get_tree().current_scene
	return combat_manager.get_players()
	
func player_exists(p: CharacterParent) -> bool:
	return p != null and is_instance_valid(p)
	
func get_combat_manager() -> CombatManager:
	if curr_game_state == GameState.MainMenu or curr_game_state == GameState.CharacterSelection: return null
	
	var combat_manager = get_tree().current_scene
	return combat_manager


func show_countdown() -> void:
	# Esperar un frame para que la escena nueva se dibuje
	await get_tree().process_frame

	var CountdownScene = load("res://scenes/ui/Countdown.tscn")
	var countdown_instance = CountdownScene.instantiate()

	# Añadir a la escena actual
	get_tree().current_scene.add_child(countdown_instance)

	await countdown_instance.start_countdown()

	countdown_instance.queue_free()
