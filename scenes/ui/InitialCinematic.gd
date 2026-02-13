extends Control

@onready var first_scene: AnimatedSprite2D = $First
@onready var second_scene: AnimatedSprite2D = $Second
@onready var third_scene: AnimatedSprite2D = $Third

@onready var first_timer: Timer = $FirstTimer
@onready var second_timer: Timer = $SecondTimer
@onready var third_timer: Timer = $ThirdTimer


var ended_cinematic: bool = false

func _input(event):
	if not ended_cinematic and event.is_action_pressed("pause"):
		on_third_scene_end()

func _ready() -> void:
	first_timer.timeout.connect(on_first_scene_end, CONNECT_ONE_SHOT)
	second_timer.timeout.connect(on_second_scene_end, CONNECT_ONE_SHOT)
	third_timer.timeout.connect(on_third_scene_end, CONNECT_ONE_SHOT)

	
	first_scene.play("default")
	first_timer.start()

func on_first_scene_end():
	first_scene.visible = false
	second_scene.visible = true
	second_scene.play("default")
	second_timer.start()

func on_second_scene_end():
	second_scene.visible = false
	third_scene.visible = true
	third_scene.play("default")
	third_timer.start()

func on_third_scene_end():
	if ended_cinematic: return
	ended_cinematic = true
	SignalContainer.game_show_title_screen.emit()

func _exit_tree() -> void:
	if first_timer.timeout.is_connected(on_first_scene_end):
		first_timer.timeout.disconnect(on_first_scene_end)
		
	if second_timer.timeout.is_connected(on_second_scene_end):
		second_timer.timeout.disconnect(on_second_scene_end)
		
	if third_timer.timeout.is_connected(on_third_scene_end):
		third_timer.timeout.disconnect(on_third_scene_end)
