extends Panel

@export var slide_value: int = 448

#audio
@onready var master_bus: int = AudioServer.get_bus_index("Master")

@onready var dark_mode_option: Node = $ScrollContainer/Control/Display/DarkMode

@onready var fullscreen_option: Node = $ScrollContainer/Control/Display/Fullscreen

@onready var master_volume_slider: Node = $ScrollContainer/Control/Sound/Volume/MasterVolumeSlider
@onready var master_volume_value_label: Node = $ScrollContainer/Control/Sound/Volume/MasterVolumeValueLabel

@onready var scroll_speed_slider: Node = $ScrollContainer/Control/Gameplay/ScrollSpeed/ScrollSpeedSlider
@onready var scroll_speed_value_label: Node = $ScrollContainer/Control/Gameplay/ScrollSpeed/ScrollSpeedValueLabel
@onready var upscroll_option: Node = $ScrollContainer/Control/Gameplay/Upscroll

var current_theme_path: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHandler.connect("toggle_show_title_screen_options", Callable(self, "toggle_options_visibility"))
	if GlobalData.global_settings["theme_name"] == "dark":
		dark_mode_option.button_pressed = true
	master_volume_slider.value = GlobalData.global_settings["master_volume"]
	scroll_speed_slider.value = GlobalData.global_settings["scroll_speed"]
	fullscreen_option.button_pressed = GlobalData.global_settings["fullscreen"]
	upscroll_option.button_pressed = GlobalData.global_settings["upscroll"]
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var evLocal: InputEvent = make_input_local(event)
		if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
			release_focus()
			SignalHandler.emit_signal("toggle_show_title_screen_options", false)
	
func toggle_options_visibility(status: bool) -> void:
	var tween: Tween = get_tree().create_tween()
	if status:
		tween.tween_property(self, "position", Vector2(1280 - slide_value, self.position.y), 0.25).set_trans(Tween.TRANS_SINE)
	else:
		tween.tween_property(self, "position", Vector2(1280, self.position.y), 0.25)

func _on_dark_mode_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var new_theme: Theme = load("res://styles/dark_theme.tres")
		GlobalData.global_settings["theme_name"] = "dark"
		SignalHandler.emit_signal("change_theme", new_theme)
	else:
		var new_theme: Theme = load("res://styles/default_theme.tres")
		GlobalData.global_settings["theme_name"] = "light"
		SignalHandler.emit_signal("change_theme", new_theme)
	DataSaver.save_data()

func _on_global_volume_slider_value_changed(value: float) -> void:
	#change master volume
	#audio related stuff should be handled by the conductor or similar nodes
	GlobalData.global_settings["master_volume"] = value
	master_volume_value_label.text = "%3.2f" % value
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	DataSaver.save_data()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GlobalData.global_settings["fullscreen"] = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		GlobalData.global_settings["fullscreen"] = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DataSaver.save_data()

func _on_scroll_speed_slider_value_changed(value: float) -> void:
	GlobalData.global_settings["scroll_speed"] = value
	DataSaver.save_data()
	scroll_speed_value_label.text = "%3.2f" % value

func _on_upscroll_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GlobalData.global_settings["upscroll"] = true
	else:
		GlobalData.global_settings["upscroll"] = false
	DataSaver.save_data()
