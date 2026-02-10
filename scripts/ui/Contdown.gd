extends CanvasLayer

func start_countdown() -> void:
	for i in range(3, 0, -1):
		$Label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	$Label.text = "GO!"
	await get_tree().create_timer(0.5).timeout
