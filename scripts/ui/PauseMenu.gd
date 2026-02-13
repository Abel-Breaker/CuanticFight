extends CanvasLayer

@onready var panel : Panel = $Panel
@onready var resume_btn : Button = $Panel/Resume
@onready var main_menu_btn : Button = $Panel/MainMenu

@onready var confirmation_panel : Panel = $Panel/ExitConfirmation
@onready var confirmation_yes_btn : Button = $Panel/ExitConfirmation/Yes
@onready var confirmation_cancel_btn : Button = $Panel/ExitConfirmation/Cancel

func _ready() -> void:
	resume_btn.grab_focus()
	resume_btn.button_up.connect(on_resume_press)
	main_menu_btn.button_up.connect(on_main_menu_press)
	confirmation_yes_btn.button_up.connect(on_yes_press)
	confirmation_cancel_btn.button_up.connect(on_cancel_press)


func on_resume_press():
	SignalContainer.game_resume.emit()

func on_main_menu_press():
	confirmation_panel.visible = true
	confirmation_cancel_btn.grab_focus()

func on_yes_press():
	confirmation_panel.visible = false
	SignalContainer.game_exit.emit()

func on_cancel_press():
	confirmation_panel.visible = false
	resume_btn.grab_focus()

func _exit_tree() -> void:
	#print("DEBUG: Disconnecting pause menu buttons")
	resume_btn.button_up.disconnect(on_resume_press)
	main_menu_btn.button_up.disconnect(on_main_menu_press)
	confirmation_yes_btn.button_up.disconnect(on_yes_press)
	confirmation_cancel_btn.button_up.disconnect(on_cancel_press)
