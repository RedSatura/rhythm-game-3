extends Node2D

@onready var status_label: Node = $UI/ScrollContainer/StatusLabel
@onready var song_info: Node = $UI/SongInfo

func _ready() -> void:
	SignalHandler.connect("send_error", Callable(self, "error_sent"))
	SignalHandler.connect("send_message", Callable(self, "message_sent"))
	SignalHandler.connect("clear_status_label", Callable(self, "clear_status_label"))
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("reset_to_defaults", Callable(self, "reset_to_defaults"))
	SignalHandler.connect("change_theme", Callable(self, "change_theme"))
	OS.request_permissions()
	song_info.visible = false

func _on_song_file_picker_file_selected(path: String) -> void:
	status_label.text = "Loading %s..." % [path]

func error_sent(message: String) -> void:
	status_label.text += str(message + '\n')
	
func message_sent(message: String) -> void:
	status_label.text += str(message + '\n')

func clear_status_label() -> void:
	status_label.text = ""
	
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
	
func change_theme(theme_path: String) -> void:
	var new_theme: Theme = load(theme_path)
	$UI.theme = new_theme
	
