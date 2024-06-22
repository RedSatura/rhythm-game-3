extends Node2D

@onready var song_manager = $SongManager
@onready var note_feedback_label = $NoteFeedbackLabel

@export var in_editor = false

var song_path = ""

func _ready():
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _on_pause_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true

func process_song_end():
	pass
