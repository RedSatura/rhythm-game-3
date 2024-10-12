extends Panel

@export var slide_value: int = 448

@onready var fullscreen_option: Node = $Display/Fullscreen

@onready var scroll_speed_slider: Node = $Gameplay/ScrollSpeed/ScrollSpeedSlider
@onready var scroll_speed_value_label: Node = $Gameplay/ScrollSpeed/ScrollSpeedValueLabel

var current_theme_path: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHandler.connect("toggle_show_title_screen_options", Callable(self, "toggle_options_visibility"))
	if GlobalData.global_settings["theme_name"] == "dark":
		$Display/DarkMode.button_pressed = true
	$Sound/Volume/MasterVolumeSlider.value = GlobalData.global_settings["master_volume"]
	scroll_speed_slider.value = GlobalData.global_settings["scroll_speed"]
	fullscreen_option.button_pressed = GlobalData.global_settings["fullscreen"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
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
