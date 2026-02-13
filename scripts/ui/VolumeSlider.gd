extends HSlider

@export var bus_name: String = "Master"
@export var display_label: Label

@onready var focus_sound: AudioStreamPlayer = $Focus
@onready var release_sound: AudioStreamPlayer = $Release

var arrow_key_pressed = false

func _ready() -> void:
	value = AudioManager.get_bus_volume(bus_name)
	
	if display_label:
		update_label()
	
	value_changed.connect(on_value_changed)
	focus_entered.connect(on_focus)
	drag_ended.connect(on_drag_end)

func on_drag_end(_value_changed:bool):
	AudioManager.play_sound_safe(release_sound)

func on_focus():
	AudioManager.play_sound_safe(focus_sound)

func on_value_changed(new_value: float):
	AudioManager.set_bus_volume(bus_name, new_value)
	if InputTypeHelper.user_is_using_keyboard() and not arrow_key_pressed and (Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left")):
		AudioManager.play_sound_safe(release_sound)
	
	if display_label:
		update_label()

func _input(event):
	if not has_focus(): return
	
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		arrow_key_pressed = true
	if event.is_action_released("ui_right") or event.is_action_released("ui_left"):
		if arrow_key_pressed:
			arrow_key_pressed = false
			AudioManager.play_sound_safe(release_sound)

func update_label():
	display_label.text = "%s: %d%%" % [bus_name.capitalize(), int(value)]

func _exit_tree() -> void:
	value_changed.disconnect(on_value_changed)
	focus_entered.disconnect(on_focus)
	drag_ended.disconnect(on_drag_end)
