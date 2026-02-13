extends Control

@onready var first_scene: AnimatedSprite2D = $First
@onready var second_scene: AnimatedSprite2D = $Second
@onready var third_scene: AnimatedSprite2D = $Third

var ended_cinematic: bool = false

func _input(event):
	if not ended_cinematic and event.is_action_pressed("pause"):
		on_third_scene_end()

func _ready() -> void:
	first_scene.animation_finished.connect(on_first_scene_end, CONNECT_ONE_SHOT)
	second_scene.animation_finished.connect(on_second_scene_end, CONNECT_ONE_SHOT)
	third_scene.animation_finished.connect(on_third_scene_end, CONNECT_ONE_SHOT)
	
	first_scene.play("default")

func on_first_scene_end():
	first_scene.visible = false
	second_scene.visible = true
	second_scene.play("default")

func on_second_scene_end():
	second_scene.visible = false
	third_scene.visible = true
	third_scene.play("default")

func on_third_scene_end():
	if ended_cinematic: return
	ended_cinematic = true
	SignalContainer.game_show_title_screen.emit()

func _exit_tree() -> void:
	if first_scene.animation_finished.is_connected(on_first_scene_end):
		first_scene.animation_finished.disconnect(on_first_scene_end)
		
	if second_scene.animation_finished.is_connected(on_second_scene_end):
		second_scene.animation_finished.disconnect(on_second_scene_end)
		
	if third_scene.animation_finished.is_connected(on_third_scene_end):
		third_scene.animation_finished.disconnect(on_third_scene_end)
