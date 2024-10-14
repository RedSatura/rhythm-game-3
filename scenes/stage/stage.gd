extends Node2D

@onready var song_manager: Node = $SongManager

@onready var lyric_label: Node = $UI/LyricLabel

@export var in_editor: bool = false

var song_path: String = ""

func _ready() -> void:
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("update_lyric", Callable(self, "update_lyric"))
	$UI.theme = GlobalData.global_settings["theme"]
	
	if GlobalData.global_settings["upscroll"]:
		lyric_label.position.y = 596
	
func error_received(error: String) -> void:
	print_debug(error)

func _on_button_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/title/title_screen.tscn")

func _on_pause_button_pressed() -> void:
	pause_song()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_song()

func process_song_end() -> void:
	pass

func pause_song() -> void:
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func update_lyric(lyric: String) -> void:
	lyric_label.text = lyric
