extends Node

signal program_close(exit_code : int)

signal game_start
signal game_finish(winner_player: int)
signal game_pause
signal game_resume
signal game_exit
signal game_replay

signal player_received_damage(receiver_player: int, remaining_health: int, max_health: int)
signal player_changed_looking_direction(player: int, new_direction: int)
