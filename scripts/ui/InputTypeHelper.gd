extends Control

var keyboard_navigation_active = false

func _input(event):
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or \
		event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or \
		event.is_action_pressed("ui_accept"):
		keyboard_navigation_active = true
	
	if event is InputEventMouseMotion:
		keyboard_navigation_active = false

func user_is_using_keyboard():
	return keyboard_navigation_active
