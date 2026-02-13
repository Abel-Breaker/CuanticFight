extends Node

@export var from_center: bool
@export var scale_on_press: Vector2
@export var scale_on_hover: Vector2
@export var anim_time: float
@export var transition_type: Tween.TransitionType

@onready var sound_entered: AudioStreamPlayer = $Entered
@onready var sound_press: AudioStreamPlayer = $PressDown
@onready var sound_release: AudioStreamPlayer = $Release

var parent#: Button
var default_scale: Vector2
var tween : Tween

func _ready() -> void:
	
	parent = get_parent()
	if from_center:
		parent.pivot_offset_ratio = Vector2(0.5, 0.5)
	
	parent.mouse_entered.connect(on_mouse_entered)
	parent.mouse_exited.connect(on_mouse_exited)
	parent.button_down.connect(on_button_down)
	parent.pressed.connect(on_press)
	parent.focus_entered.connect(on_focus)
	
	call_deferred("init")

func on_mouse_entered():
	sound_entered.play()
	play_scale_tween(scale_on_hover)

func on_mouse_exited():
	play_scale_tween(default_scale)

func on_button_down():
	AudioManager.play_sound_safe(sound_press)
	if not InputTypeHelper.user_is_using_keyboard():
		play_scale_tween(scale_on_press)

func on_press():
	if self.is_inside_tree():
		if InputTypeHelper.user_is_using_keyboard():
			AudioManager.play_sound_safe(sound_release)
		else:
			sound_release.play()
			play_scale_tween(scale_on_hover)

func on_focus():
	if InputTypeHelper.user_is_using_keyboard():
		AudioManager.play_sound_safe(sound_entered)


func init() -> void:
	default_scale = parent.scale


func play_scale_tween(target_scale: Vector2) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(parent, "scale", target_scale, anim_time).set_trans(transition_type)

func _exit_tree() -> void:
	parent.mouse_entered.disconnect(on_mouse_entered)
	parent.mouse_exited.disconnect(on_mouse_exited)
	parent.button_down.disconnect(on_button_down)
	parent.pressed.disconnect(on_press)
	parent.focus_entered.disconnect(on_focus)
