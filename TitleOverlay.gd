extends CanvasLayer

@onready var start_btn: Button = $Start

func _ready() -> void:
	start_btn.grab_focus()
	start_btn.button_up.connect(on_user_interaction)

func on_user_interaction():
	visible = false

func _exit_tree() -> void:
	start_btn.button_up.disconnect(on_user_interaction)
