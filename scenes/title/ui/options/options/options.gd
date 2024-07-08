extends Panel

@export var slide_value: int = 448

var current_theme_path: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHandler.connect("toggle_show_title_screen_options", Callable(self, "toggle_options_visibility"))
	if GlobalData.global_settings["theme_name"] == "dark":
		$Display/DarkMode.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func toggle_options_visibility(status: bool) -> void:
	if status:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(1280 - slide_value, self.position.y), 0.25).set_trans(Tween.TRANS_SINE)
	else:
		var tween: Tween = get_tree().create_tween()
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
