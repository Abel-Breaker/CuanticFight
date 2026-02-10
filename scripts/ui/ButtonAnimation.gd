extends Node

@export var from_center: bool
@export var scale_on_press: Vector2
@export var scale_on_hover: Vector2
@export var anim_time: float
@export var transition_type: Tween.TransitionType

@onready var sound_entered: AudioStreamPlayer = $Entered
@onready var sound_press: AudioStreamPlayer = $PressDown
@onready var sound_release: AudioStreamPlayer = $Release

var parent: Button
var default_scale: Vector2
var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	parent = get_parent()
	if from_center:
		parent.pivot_offset_ratio = Vector2(0.5, 0.5)
		
	parent.mouse_entered.connect(func ():
		sound_entered.play()
		play_scale_tween(scale_on_hover)
	)
	parent.mouse_exited.connect(func ():
		play_scale_tween(default_scale)
	)
	parent.button_down.connect(func ():
		sound_press.play()
		play_scale_tween(scale_on_press)
	)
	parent.button_up.connect(func ():
		if self.is_inside_tree():
			sound_release.play()
			play_scale_tween(scale_on_hover)
	)
	
	call_deferred("init")
	
	
func init() -> void:
	default_scale = parent.scale
	

func play_scale_tween(target_scale: Vector2) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(parent, "scale", target_scale, anim_time).set_trans(transition_type)
	
