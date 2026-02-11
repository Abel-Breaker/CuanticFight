extends CanvasLayer

@onready var sound: AudioStreamPlayer = $Sound
@onready var panel: Panel = $Panel

func start_countdown() -> void:
	panel.visible = true
	AudioManager.play_sound_safe(sound)
	
	for i in range(2, 0, -1):
		$Label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	$Label.text = "GO!"
	panel.visible = false
	await get_tree().create_timer(0.5).timeout
