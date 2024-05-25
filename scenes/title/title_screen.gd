extends Node2D

@onready var status_label = $ScrollContainer/StatusLabel
@onready var song_info = $SongInfo

func _ready():
	SignalHandler.connect("send_error", Callable(self, "error_sent"))
	SignalHandler.connect("send_message", Callable(self, "message_sent"))
	SignalHandler.connect("clear_status_label", Callable(self, "clear_status_label"))
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("reset_to_defaults", Callable(self, "reset_to_defaults"))
	OS.request_permissions()
	song_info.visible = false

func _on_song_file_picker_file_selected(path):
	status_label.text = "Loading %s..." % [path]

func error_sent(message):
	status_label.text += str(message + '\n')
	
func message_sent(message):
	status_label.text += str(message + '\n')

func clear_status_label():
	status_label.text = ""
	
func song_validated():
	song_info.visible = true
	$SongInfo/SongDataLabels/Title.text = "Title: " + str(GlobalData.song_info["title"])
	$SongInfo/SongDataLabels/Artist.text = "Artist: " + str(GlobalData.song_info["artist"])
	$SongInfo/SongDataLabels/MapCreator.text = "Map Creator: " + str(GlobalData.song_info["mapcreator"])
	$SongInfo/SongDataLabels/Difficulty.text = "Difficulty: " + str(GlobalData.song_info["difficulty"])
	
func reset_to_defaults():
	song_info.visible = false

func _on_play_song_pressed():
	get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")

func _on_editor_button_pressed():
	get_tree().change_scene_to_file("res://scenes/editor/song_editor.tscn")
