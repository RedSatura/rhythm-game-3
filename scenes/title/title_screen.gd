extends Node2D

@onready var song_info: Node = $UI/SongInfo

@onready var messages_container: Node = $UI/ScrollContainer/MessagesContainer

@onready var song_selection: Node = $UI/SongSelection

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	randomize()
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("send_message", Callable(self, "message_received"))
	SignalHandler.connect("clear_status_label", Callable(self, "clear_status_label"))
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("reset_to_defaults", Callable(self, "reset_to_defaults"))
	SignalHandler.connect("change_theme", Callable(self, "change_theme"))
	
	OS.request_permissions()
	
	song_info.visible = false
	
	if GlobalData.global_settings["theme"] == null:
		GlobalData.global_settings["theme"] = load("res://styles/default_theme.tres")
		$UI.theme = GlobalData.global_settings["theme"]
	else:
		$UI.theme = GlobalData.global_settings["theme"]
		
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
	song_info.visible = true
	$UI/SongInfo/SongDataLabels/Title.text = str(GlobalData.song_info["title"])
	$UI/SongInfo/SongDataLabels/Artist.text = "Artist: " + str(GlobalData.song_info["artist"])
	$UI/SongInfo/SongDataLabels/MapCreator.text = "Map Creator: " + str(GlobalData.song_info["mapcreator"])
	$UI/SongInfo/SongDataLabels/Difficulty.text = "Difficulty: " + str(GlobalData.song_info["difficulty"])
	
func reset_to_defaults() -> void:
	song_info.visible = false

func _on_play_song_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")

func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/editor/song_editor.tscn")
	
func change_theme(theme: Theme) -> void:
	$UI.theme = theme
	GlobalData.global_settings["theme"] = theme

func _on_official_song_button_pressed() -> void:
	SignalHandler.emit_signal("send_song_to_validator", "res://songs/official/0.4/gateway/gateway.msf")
	get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")
