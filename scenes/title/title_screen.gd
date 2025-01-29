extends Node2D

@onready var messages_container: Node = $UI/ScrollContainer/MessagesContainer

@onready var song_selection: Node = $UI/SongSelection

@onready var title_objects: Node = $UI/TitleObjects

@onready var song_previewer: Node = $SongPreviewer

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	randomize()
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("send_message", Callable(self, "message_received"))
	SignalHandler.connect("clear_status_label", Callable(self, "clear_status_label"))
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("reset_to_defaults", Callable(self, "reset_to_defaults"))
	SignalHandler.connect("change_theme", Callable(self, "change_theme"))
	SignalHandler.connect("set_song_selection_visibility", Callable(self, "song_selection_visibility_status"))
	GlobalData.song_info["video_src"] = ""
	GlobalData.song_info["image_src"] = ""
	$UI/TitleObjects/Play.grab_focus()
	
	OS.request_permissions()
	
	if GlobalData.global_settings["theme"] == null:
		GlobalData.global_settings["theme"] = load("res://styles/default_theme.tres")
		$UI.theme = GlobalData.global_settings["theme"]
	else:
		$UI.theme = GlobalData.global_settings["theme"]
		
	if GlobalData.global_settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _on_song_file_picker_file_selected(path: String) -> void:
	SignalHandler.emit_signal("send_message", "Loading %s" % path)

func error_received(error: String) -> void:
	var message_display: Node = load("res://scenes/ui/message_display/message_display.tscn").instantiate()
	messages_container.add_child(message_display)
	message_display.update_message(1, error)
	
func message_received(message: String) -> void:
	var message_display: Node = load("res://scenes/ui/message_display/message_display.tscn").instantiate()
	messages_container.add_child(message_display)
	message_display.update_message(0, message)
	
func song_validated() -> void:
	if FileAccess.file_exists(GlobalData.song_info["audio_src"]):
		song_previewer.stream = AudioStreamOggVorbis.load_from_file(GlobalData.song_info["audio_src"])
	elif ResourceLoader.exists(GlobalData.song_info["audio_src"]):
		song_previewer.stream = ResourceLoader.load(GlobalData.song_info["audio_src"])
	
	if song_previewer:
		song_previewer.play()
	
func reset_to_defaults() -> void:
	pass
	
func change_theme(theme: Theme) -> void:
	$UI.theme = theme
	GlobalData.global_settings["theme"] = theme

func _on_song_editor_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/editor/song_editor.tscn")

func _on_play_pressed() -> void:
	SignalHandler.emit_signal("set_song_selection_visibility", true)
	SignalHandler.emit_signal("toggle_show_title_screen_options", false)

func song_selection_visibility_status(status: bool) -> void:
	if status:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(title_objects, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.3)
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(title_objects, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
		$UI/TitleObjects/Play.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()
