extends Node2D

@onready var song_manager: Node = $SongManager
@onready var note_feedback_label: Node = $NoteFeedbackLabel

@export var in_editor: bool = false

var song_path: String = ""

func _ready() -> void:
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _on_pause_button_pressed() -> void:
	pause_song()
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_song()

func process_song_end() -> void:
	pass

func pause_song() -> void:
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true
