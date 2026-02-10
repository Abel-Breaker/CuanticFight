extends Node
@warning_ignore("unused_signal")
signal program_close(exit_code : int)

@warning_ignore("unused_signal")
signal game_character_selection(solo: bool)
@warning_ignore("unused_signal")
signal game_start(p1_type: ProyectilesManager.ProyectileType, p2_type: ProyectilesManager.ProyectileType, solo: bool, recolorP1 : bool, recolorP2 : bool)
@warning_ignore("unused_signal")
signal game_finish(winner_player: int)
@warning_ignore("unused_signal")
signal game_pause
@warning_ignore("unused_signal")
signal game_resume
@warning_ignore("unused_signal")
signal game_exit
@warning_ignore("unused_signal")
signal game_replay
@warning_ignore("unused_signal")
signal game_go_back_to_main_menu

@warning_ignore("unused_signal")
signal player_received_damage(receiver_player: int, remaining_health: int, max_health: int)
@warning_ignore("unused_signal")
signal player_changed_looking_direction(player: int, new_direction: int)
@warning_ignore("unused_signal")
signal player_duplicated_himself(player: int)
@warning_ignore("unused_signal")
signal player_determined_himself(player: int)
