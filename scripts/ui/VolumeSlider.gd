extends HSlider

@export var bus_name: String = "Master"
@export var display_label: Label


func _ready() -> void:
	value = AudioManager.get_bus_volume(bus_name)
	
	if display_label:
		update_label()
	
	value_changed.connect(on_value_changed)

func on_value_changed(new_value: float):
	AudioManager.set_bus_volume(bus_name, new_value)
	
	if display_label:
		update_label()

func update_label():
	display_label.text = "%s: %d%%" % [bus_name.capitalize(), int(value)]
