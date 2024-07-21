extends FileDialog

func _ready() -> void:
	set_use_native_dialog(false)

func _on_file_selected(path: String) -> void:
	SignalHandler.emit_signal("send_song_to_validator", path)

func _on_open_file_pressed() -> void:
	SignalHandler.emit_signal("clear_status_label")
	SignalHandler.emit_signal("reset_to_defaults")
	popup()
