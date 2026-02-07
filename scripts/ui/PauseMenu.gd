extends Panel

@onready var resume_btn : Button = $Resume
@onready var main_menu_btn : Button = $MainMenu

@onready var confirmation_panel : Panel = $ExitConfirmation
@onready var confirmation_yes_btn : Button = $ExitConfirmation/Yes
@onready var confirmation_cancel_btn : Button = $ExitConfirmation/Cancel

func _ready() -> void:
	
	resume_btn.button_up.connect(on_resume_press)
	main_menu_btn.button_up.connect(on_main_menu_press)
	confirmation_yes_btn.button_up.connect(on_yes_press)
	confirmation_cancel_btn.button_up.connect(on_cancel_press)


func on_resume_press():
	SignalContainer.game_resume.emit()

func on_main_menu_press():
	confirmation_panel.visible = true

func on_yes_press():
	SignalContainer.game_exit.emit()

func on_cancel_press():
	confirmation_panel.visible = false

func _exit_tree() -> void:
	resume_btn.button_up.disconnect(on_resume_press)
	main_menu_btn.button_up.disconnect(on_main_menu_press)
	confirmation_yes_btn.button_up.disconnect(on_yes_press)
	confirmation_cancel_btn.button_up.disconnect(on_cancel_press)
