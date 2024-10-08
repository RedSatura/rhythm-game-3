extends Node2D

@onready var song_manager: Node = $SongManager
@onready var note_feedback_label: Node = $UI/NoteFeedbackLabel

@export var in_editor: bool = false

var song_path: String = ""

func _ready() -> void:
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	$UI.theme = GlobalData.global_settings["theme"]
	
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
